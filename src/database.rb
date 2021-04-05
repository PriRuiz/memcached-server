require_relative('data_entry')

class Database

  def initialize()
    @data = {}
  end

  def is_empty?()
    return @data == {}
  end

  def data_entry(key)
    @data[key]
  end

  def store_data_entry(key, flags, exptime, bytes, body, cas_unique)
    data_entry = DataEntry.new(flags, exptime, bytes, body, cas_unique)
    @data[key] = data_entry
  end

  def has_key?(key)
    @data.has_key?(key)
  end

  def each_key()
    @data.each_key
  end

  def delete(key)
    @data.delete(key)
  end

end
