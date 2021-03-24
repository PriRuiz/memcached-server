require 'socket' #get sockets from stdlib

class Server

  def initializeServer()
    serverSocket = TCPServer.open('127.0.0.1', 2000) #socket to listen on port 2000
    data = {}
    loop {
      Thread.start() do
        purgeKeys(data)
      end
      Thread.start(serverSocket.accept) do |client|
        handleClient(data, client)
      end
    }
  end

  def purgeKeys(data)
    while true
      data.each_key do |key|
        bloque = data[key]
        exptime = bloque["exptime"].to_i
        if exptime != 0 && exptime < Time.now.to_i
          data.delete(key)
        end
      end
      sleep 300
    end
  end

  def handleClient(data, client)
    client.puts "Welcome!\r"
    while line = client.gets
      command,key,parameters = line.split(" ", 3).delete_if(&:empty?)

      case command

      when "set"
        set(command, key, parameters, data, client)

      when "add"
        add(command, key, parameters, data, client)

      when "replace"
        replace(command, key, parameters, data, client)

      when "append"
        append(command, key, parameters, data, client)

      when "prepend"
        prepend(command, key, parameters, data, client)

      when "cas"
        cas(command, key, parameters, data, client)

      when "get"
        get(command, key, parameters, data, client)

      when "gets"
        gets(command, key, parameters, data, client)

      when "quit"
        client.close()
        return
      else
        client.puts "ERROR\r"
      end
    end
  end

  # Error strings
  def error_detection(command, key, parameters, cas_unique, data, client)
    if key.nil? || key.length > 250
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
        if !(flags =~ /^-?[0-9]+$/) || 0 > flags.to_i || flags.to_i > 65535
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
  def store(key, flags, exptime, bytes, cas_unique, data, client)
    body = client.read(bytes.to_i + 2)

    last_two = body.chars.last(2).join
    if (bytes.to_i != 0) && !("\r\n".eql? last_two)
      client.puts 'Data blocks must end with \r\n'"\r"
      return
    end

    if !body.nil?
      body = body.strip
    end

    bloque = {}
    bloque["flags"] = flags
    bloque["exptime"] = exptime
    bloque["bytes"] = bytes
    bloque["body"] = body
    bloque["cas_unique"] = cas_unique

    data[key] = bloque

    client.puts "STORED\r"
  end

  # Auxiliar method.
  # Splits up the parameters given by the client.
  # Returns flags, exptime and bytes values.
  def parameters_split(command,parameters)
    if !parameters.nil?
      if "cas" == command
        flags,exptime,bytes,cas_unique= parameters.split(" ", 4).delete_if(&:empty?)
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

  # Stores data.
  def set(command, key, parameters, data, client)
    flags,exptime,bytes = parameters_split(command, parameters)

    if !data.has_key?(key)
      cas_unique = 1
    elsif data.has_key?(key)
      bloque = data[key]
      cas_unique = bloque["cas_unique"] + 1
    end

    if !error_detection(command, key, parameters, cas_unique, data, client)
      store(key, flags, exptime, bytes, cas_unique, data, client)
    end
  end

  # Stores data but only if the server does not already hold data for this key.
  def add(command, key, parameters, data, client)
    flags,exptime,bytes = parameters_split(command, parameters)

    cas_unique = 1

    if !error_detection(command, key, parameters, cas_unique, data, client)
      if !data.has_key?(key)
        store(key, flags, exptime, bytes, cas_unique, data, client)
      else
        client.puts "NOT_STORED\r"
      end
    end
  end

  # Stores data but only if the server does already hold data for this key.
  def replace(command, key, parameters, data, client)
    flags,exptime,bytes = parameters_split(command, parameters)

    cas_unique = nil

    if !error_detection(command, key, parameters, cas_unique, data, client)
      if data.has_key?(key)
        bloque = data[key]
        cas_unique = bloque["cas_unique"] + 1
        store(key, flags, exptime, bytes, cas_unique, data, client)
      else
        client.puts "NOT_STORED\r"
      end
    end
  end

  # Adds data to an existing key after existing data.
  def append(command, key, parameters, data, client)
    cas_unique = nil

    if !parameters.nil?
      parameters = parameters.strip
    end

    if !error_detection(command, key, parameters, cas_unique, data, client)
      body = client.read(parameters.to_i + 2)

      last_two = body.chars.last(2).join
      if (parameters.to_i != 0) && !("\r\n".eql? last_two)
        client.puts 'Data blocks must end with \r\n'"\r"
        return
      end

      if !body.nil?
        body = body.strip
      end

      if data.has_key?(key)
        bloque = data[key]
        bytes = bloque["bytes"].to_i + parameters.to_i + 1
        bloque["body"] = bloque["body"] + " " + body
        bloque["bytes"] = bytes.to_s
        bloque["cas_unique"] = bloque["cas_unique"] + 1
        client.puts "STORED\r"
      else
        client.puts "CLIENT_ERROR the key does not exist\r"
      end
    end
  end

  # Adds data to an existing key before existing data.
  def prepend(command, key, parameters, data, client)
    cas_unique = nil

    if !parameters.nil?
      parameters = parameters.strip
    end

    if !error_detection(command, key, parameters, cas_unique, data, client)
      body = client.read(parameters.to_i + 2)

      last_two = body.chars.last(2).join
      if (parameters.to_i != 0) && !("\r\n".eql? last_two)
        client.puts 'Data blocks must end with \r\n'"\r"
        return
      end

      if !body.nil?
        body = body.strip
      end

      if data.has_key?(key)
        bloque = data[key]
        bytes = bloque["bytes"].to_i + parameters.to_i + 1
        bloque["body"] = body + " " + bloque["body"]
        bloque["bytes"] = bytes.to_s
        bloque["cas_unique"] = bloque["cas_unique"] + 1
        client.puts "STORED\r"
      else
        client.puts "CLIENT_ERROR the key does not exist\r"
      end
    end
  end

  # Stores data but only if no one has updated the item since last fetched by the client.
  def cas(command, key, parameters, data, client)
    flags,exptime,bytes,cas_unique = parameters_split(command, parameters)

    if !error_detection(command, key, parameters, cas_unique, data, client)
      if !data.has_key?(key)
        client.puts "NOT_FOUND\r"
      else
        bloque = data[key]
        unique_key = bloque["cas_unique"]
        if unique_key.eql? cas_unique.to_i
          cas_unique = cas_unique.to_i + 1
          store(key, flags, exptime, bytes, cas_unique, data, client)
        else
          client.puts "EXISTS\r"
        end
      end
    end
  end

  # Sends the items requested by the client.
  # Each of which is received as a text line followed by a data block.
  def get(command, key, parameters, data, client)
    cas_unique = nil
    if !error_detection(command, key, parameters, cas_unique, data, client)
      while !key.nil?
        if data.has_key?(key)
          bloque = data[key]
          exptime = bloque["exptime"]
          if exptime.to_i > Time.now.to_i || exptime.to_i == 0
            client.puts "VALUE" + " " + key + " " + bloque["flags"] + " " + bloque["bytes"] + "\r\n" + bloque["body"] + "\r"
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
  def gets(command, key, parameters, data, client)
    cas_unique = nil

    if !error_detection(command, key, parameters, cas_unique, data, client)
      while !key.nil?
        if data.has_key?(key)
          bloque = data[key]
          exptime = bloque["exptime"]
          if exptime.to_i > Time.now.to_i || exptime.to_i == 0
            client.puts "VALUE" + " " + key + " " + bloque["flags"] + " " + bloque["bytes"] + " " + bloque["cas_unique"].to_s + "\r\n" + bloque["body"] + "\r"
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
