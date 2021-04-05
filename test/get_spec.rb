require_relative '../src/server'

RSpec.configure do |config|
  config.formatter = :documentation
end

describe Service do
  describe 'get' do
    it 'returns the items requested by the client when said items exist' do
      service = Service.new

      command = "get"
      parameters = "5123456 3123456"
      key = "4123456"
      database = service.database()
      client = double("client")

      database.store_data_entry("4123456", "10", "0", "13", "Priscila Ruiz", 1)
      database.store_data_entry("5123456", "10", "0", "10", "Juan Perez", 1)
      database.store_data_entry("3123456", "10", "0", "18", "Agustina Rodriguez", 1)

      #this is the behavior beeing tested
      expect(client).to receive(:puts).with("VALUE 4123456 10 13\r\nPriscila Ruiz\r").ordered
      expect(client).to receive(:puts).with("VALUE 5123456 10 10\r\nJuan Perez\r").ordered
      expect(client).to receive(:puts).with("VALUE 3123456 10 18\r\nAgustina Rodriguez\r").ordered
      expect(client).to receive(:puts).with("END\r").ordered

      service.get(command, key, parameters, client)
    end

    it 'only returns the existing items requested by the client' do
      service = Service.new

      command = "get"
      parameters = "5123456 3123456"
      key = "4123456"
      database = service.database()
      client = double("client")

      database.store_data_entry("4123456", "10", "0", "13", "Priscila Ruiz", 1)
      database.store_data_entry("3123456", "10", "0", "18", "Agustina Rodriguez", 1)

      #this is the behavior beeing tested
      expect(client).to receive(:puts).with("VALUE 4123456 10 13\r\nPriscila Ruiz\r").ordered
      expect(client).to receive(:puts).with("VALUE 3123456 10 18\r\nAgustina Rodriguez\r").ordered
      expect(client).to receive(:puts).with("END\r").ordered

      service.get(command, key, parameters, client)
    end

    it 'does not return anything if no key was given' do
      service = Service.new

      command = "get"
      key = nil
      parameters = nil
      database = service.database()
      client = double("client")

      #this is the behavior beeing tested
      expect(client).to receive(:puts).with("CLIENT_ERROR a key must be given and cannot exceed 250 characters\r")

      service.gets(command, key, parameters, client)
    end
  end
end
