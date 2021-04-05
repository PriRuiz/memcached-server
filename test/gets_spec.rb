require_relative '../src/server'

RSpec.configure do |config|
  config.formatter = :documentation
end

describe Service do
  describe 'gets' do
    it 'returns the items requested by the client when said items exist and includes cas unique keys' do
      service = Service.new

      command = "gets"
      parameters = "5123456 3123456"
      key = "4123456"
      database = service.database()
      client = double("client")

      database.store_data_entry("4123456", "10", "0", "13", "Priscila Ruiz", 1)
      database.store_data_entry("5123456", "10", "0", "10", "Juan Perez", 2)
      database.store_data_entry("3123456", "10", "0", "18", "Agustina Rodriguez", 3)

      #this is the behavior beeing tested
      expect(client).to receive(:puts).with("VALUE 4123456 10 13 1\r\nPriscila Ruiz\r").ordered
      expect(client).to receive(:puts).with("VALUE 5123456 10 10 2\r\nJuan Perez\r").ordered
      expect(client).to receive(:puts).with("VALUE 3123456 10 18 3\r\nAgustina Rodriguez\r").ordered
      expect(client).to receive(:puts).with("END\r").ordered

      service.gets(command, key, parameters, client)
    end

    it 'only returns the existing items requested by the client and includes cas unique keys' do
      service = Service.new

      command = "gets"
      parameters = "5123456 3123456"
      key = "4123456"
      database = service.database()
      client = double("client")

      database.store_data_entry("4123456", "10", "0", "13", "Priscila Ruiz", 1)
      database.store_data_entry("3123456", "10", "0", "18", "Agustina Rodriguez", 2)

      #this is the behavior beeing tested
      expect(client).to receive(:puts).with("VALUE 4123456 10 13 1\r\nPriscila Ruiz\r").ordered
      expect(client).to receive(:puts).with("VALUE 3123456 10 18 2\r\nAgustina Rodriguez\r").ordered
      expect(client).to receive(:puts).with("END\r").ordered

      service.gets(command, key, parameters, client)
    end

    it 'does not return anything if no key was given' do
      service = Service.new

      command = "gets"
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
