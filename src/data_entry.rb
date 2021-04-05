class DataEntry

  attr_accessor :flags, :exptime, :bytes, :body, :cas_unique

  def initialize(flags, exptime, bytes, body, cas_unique)
    @flags = flags
    @exptime = exptime
    @bytes = bytes
    @body = body
    @cas_unique = cas_unique
  end

end
