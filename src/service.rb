require_relative('database')
require_relative('data_entry')
require_relative('service_constants')

class Service
  include ServiceConstants

  attr_accessor :database

  def initialize()
    @database = Database.new
  end

  # Method for deleting expired keys
  def purge_keys()
    while true
      @database.each_key do |key|
        data_entry = data_entry(key)
        exptime = data_entry.exptime().to_i
        if exptime != 0 && exptime < Time.now.to_i
          @database.delete(key)
        end
      end
      sleep FIVE_MINUTES
    end
  end

  # Auxiliar method.
  # Splits up the parameters given by the client.
  # Returns flags, exptime and bytes values.
  def parameters_split(command, parameters)
    if !parameters.nil?
      if "cas" == command
        flags,exptime,bytes,cas_unique = parameters.split(" ", 4).delete_if(&:empty?)
        if !cas_unique.nil?
          cas_unique = cas_unique.strip
        end
        return flags,exptime,bytes,cas_unique
      else
        flags,exptime,bytes = parameters.split(" ", 3).delete_if(&:empty?)
        if !bytes.nil?
          bytes = bytes.strip
        end
        return flags,exptime,bytes
      end
    end
  end

  # Error strings
  def has_error?(command, key, parameters, cas_unique, client)
    if key.nil? || key.length > MAX_LENGTH_KEY
      client.puts "CLIENT_ERROR a key must be given and cannot exceed 250 characters\r"
      return true
    end

    if "set" == command || "add" == command || "replace" == command || "cas" == command

      if "cas" == command
        flags,exptime,bytes,cas_unique = parameters_split(command, parameters)
      else
        flags,exptime,bytes = parameters_split(command, parameters)
      end

      if !flags.nil? && !exptime.nil? && !bytes.nil?
        if !(flags =~ /^-?[0-9]+$/) || MIN_LENGTH_FLAGS > flags.to_i || flags.to_i > MAX_LENGTH_FLAGS
          client.puts "CLIENT_ERROR flags must be a 16-bit unsigned integer\r"
          return true
        end
        if !(exptime =~ /^-?[0-9]+$/)
          client.puts "CLIENT_ERROR exptime must be Unix Time\r"
          return true
        end
        if !(bytes =~ /^-?[0-9]+$/)
          client.puts "CLIENT_ERROR bytes must be a numeric value\r"
          return true
        end
      else
        client.puts "CLIENT_ERROR some parameters were not given\r"
        return true
      end
    end

    if "append" == command || "prepend" == command
      if parameters.nil?
        client.puts "CLIENT_ERROR bytes value must be given\r"
        return true
      elsif !(parameters =~ /^-?[0-9]+$/)
        client.puts "CLIENT_ERROR bytes must be a numeric value\r"
        return true
      end
    end

    if "cas" == command
      if cas_unique.nil?
        client.puts "CLIENT_ERROR cas unique key must be given\r"
        return true
      elsif !(cas_unique =~ /^-?[0-9]+$/)
        client.puts "CLIENT_ERROR cas unique key must be a numeric value\r"
        return true
      end
    end

    return false
  end

  # Auxiliar method for storage commands.
  def store(key, flags, exptime, bytes, cas_unique, client)
    body = client.read(bytes.to_i + 2)

    last_two = body.chars.last(2).join
    if (bytes.to_i != 0) && !("\r\n".eql? last_two)
      client.puts 'Data blocks must end with \r\n'"\r"
      return
    end

    if !body.nil?
      body = body.strip
    end

    @database.store_data_entry(key, flags, exptime, bytes, body, cas_unique)

    client.puts "STORED\r"
  end

  # Stores data.
  def set(command, key, parameters, client)
    flags,exptime,bytes = parameters_split(command, parameters)

    if !@database.has_key?(key)
      #cas_unique is initialized
      cas_unique = 1
    elsif @database.has_key?(key)
      #cas_unique is updated
      data_entry = @database.data_entry(key)
      cas_unique = data_entry.cas_unique() + 1
    end

    if !has_error?(command, key, parameters, cas_unique, client)
      store(key, flags, exptime, bytes, cas_unique, client)
    end
  end

  # Stores data but only if the server does not already hold data for this key.
  def add(command, key, parameters, client)
    flags,exptime,bytes = parameters_split(command, parameters)
    #cas_unique is initialized
    cas_unique = 1

    if !has_error?(command, key, parameters, cas_unique, client)
      if !@database.has_key?(key)
        store(key, flags, exptime, bytes, cas_unique, client)
      else
        client.puts "NOT_STORED\r"
      end
    end
  end

  # Stores data but only if the server does already hold data for this key.
  def replace(command, key, parameters, client)
    cas_unique = nil
    flags,exptime,bytes = parameters_split(command, parameters)

    if !has_error?(command, key, parameters, cas_unique, client)
      if @database.has_key?(key)
        data_entry = @database.data_entry(key)
        cas_unique = data_entry.cas_unique() + 1
        store(key, flags, exptime, bytes, cas_unique, client)
      else
        client.puts "NOT_STORED\r"
      end
    end
  end

  # Adds data to an existing key after existing data.
  def append(command, key, parameters, client)
    cas_unique = nil

    if !parameters.nil?
      parameters = parameters.strip
    end

    if !has_error?(command, key, parameters, cas_unique, client)
      body = client.read(parameters.to_i + 2)

      last_two = body.chars.last(2).join
      if (parameters.to_i != 0) && !("\r\n".eql? last_two)
        client.puts 'Data blocks must end with \r\n'"\r"
        return
      end

      if !body.nil?
        body = body.strip
      end

      if @database.has_key?(key)
        data_entry = @database.data_entry(key)
        data_entry.bytes=((data_entry.bytes().to_i + parameters.to_i + 1).to_s)
        data_entry.body=("#{data_entry.body()} #{body}")
        data_entry.cas_unique=(data_entry.cas_unique() + 1)
        client.puts "STORED\r"
      else
        client.puts "CLIENT_ERROR the key does not exist\r"
      end
    end
  end

  # Adds data to an existing key before existing data.
  def prepend(command, key, parameters, client)
    cas_unique = nil

    if !parameters.nil?
      parameters = parameters.strip
    end

    if !has_error?(command, key, parameters, cas_unique, client)
      body = client.read(parameters.to_i + 2)

      last_two = body.chars.last(2).join
      if (parameters.to_i != 0) && !("\r\n".eql? last_two)
        client.puts 'Data blocks must end with \r\n'"\r"
        return
      end

      if !body.nil?
        body = body.strip
      end

      if @database.has_key?(key)
        data_entry = @database.data_entry(key)
        data_entry.bytes=((data_entry.bytes().to_i + parameters.to_i + 1).to_s)
        data_entry.body=("#{body} #{data_entry.body()}")
        data_entry.cas_unique=(data_entry.cas_unique() + 1)
        client.puts "STORED\r"
      else
        client.puts "CLIENT_ERROR the key does not exist\r"
      end
    end
  end

  # Stores data but only if no one has updated the item since last fetched by the client.
  def cas(command, key, parameters, client)
    flags,exptime,bytes,cas_unique = parameters_split(command, parameters)

    if !has_error?(command, key, parameters, cas_unique, client)
      if !@database.has_key?(key)
        client.puts "NOT_FOUND\r"
      else
        data_entry = @database.data_entry(key)
        unique_key = data_entry.cas_unique()
        if unique_key.eql? cas_unique.to_i
          cas_unique = cas_unique.to_i + 1
          store(key, flags, exptime, bytes, cas_unique, client)
        else
          client.puts "EXISTS\r"
        end
      end
    end
  end

  # Sends the items requested by the client.
  # Each of which is received as a text line followed by a data block.
  def get(command, key, parameters, client)
    cas_unique = nil
    if !has_error?(command, key, parameters, cas_unique, client)
      while !key.nil?
        if @database.has_key?(key)
          data_entry = @database.data_entry(key)
          exptime = data_entry.exptime()
          if exptime.to_i > Time.now.to_i || exptime.to_i == 0
            client.puts "VALUE #{key} #{data_entry.flags} #{data_entry.bytes}\r\n#{data_entry.body}\r"
          end
        end
        if !parameters.nil?
          key,parameters = parameters.split(" ", 2)
        else
          key = nil
        end
      end
      client.puts "END\r"
    end
  end

  # Sends the items requested by the client.
  # Each of which is received as a text line (which includes the cas_unique key) followed by a data block.
  def gets(command, key, parameters, client)
    cas_unique = nil
    if !has_error?(command, key, parameters, cas_unique, client)
      while !key.nil?
        if @database.has_key?(key)
          data_entry = @database.data_entry(key)
          exptime = data_entry.exptime()
          if exptime.to_i > Time.now.to_i || exptime.to_i == 0
            client.puts "VALUE #{key} #{data_entry.flags} #{data_entry.bytes} #{data_entry.cas_unique.to_s}\r\n#{data_entry.body}\r"
          end
        end
        if !parameters.nil?
          key,parameters = parameters.split(" ", 2)
        else
          key = nil
        end
      end
      client.puts "END\r"
    end
  end

end
