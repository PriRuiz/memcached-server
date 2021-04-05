require_relative '../src/server'

RSpec.configure do |config|
  config.formatter = :documentation
end

describe Service do
  describe 'prepend' do
    describe 'adds data to an existing key after existing data' do
      before (:each) do
        service = Service.new

        command = "prepend"
        parameters = "7"
        @key = "4123456"
        @database = service.database()
        client = double("client")

        @database.store_data_entry("4123456", "10", "0", "13", "Priscila Ruiz", 1)

        #these 'expect' are necessary because of the server's design
        expect(client).to receive(:read).with(9).and_return("Fabiana\r\n").ordered
        expect(client).to receive(:puts).with("STORED\r").ordered

        service.prepend(command, @key, parameters, client)
      end

      it "updates the body" do
        expect(@database.data_entry(@key).body).to eq("Fabiana Priscila Ruiz")
      end
      it "updates the bytes" do
        expect(@database.data_entry(@key).bytes).to eq("21")
      end
      it "updates the cas_unique" do
        expect(@database.data_entry(@key).cas_unique).to eq(2)
      end
    end

    it 'does not store data when the server does not hold data for the given key' do
      service = Service.new

      command = "prepend"
      parameters = "7"
      key = "3123456"
      database = service.database()
      client = double("client")

      #these 'expect' are necessary because of the server's design
      expect(client).to receive(:read).with(9).and_return("Fabiana\r\n").ordered

      #this is the behavior beeing tested
      expect(client).to receive(:puts).with("CLIENT_ERROR the key does not exist\r").ordered

      service.prepend(command, key, parameters, client)
    end

    it 'does not store data if no key was recieved' do
      service = Service.new

      command = "prepend"
      key = nil
      parameters = nil
      database = service.database()
      client = double("client")

      #this is the behavior beeing tested
      expect(client).to receive(:puts).with("CLIENT_ERROR a key must be given and cannot exceed 250 characters\r").ordered

      service.prepend(command, key, parameters, client)
    end

    it 'does not store data if bytes value was not recieved' do
      service = Service.new

      command = "prepend"
      parameters = nil
      key = "4123456"
      database = service.database()
      client = double("client")

      database.store_data_entry("4123456", "10", "0", "13", "Priscila Ruiz", 1)

      #these 'expect' are necessary because of the server's design
      expect(client).to receive(:puts).with("CLIENT_ERROR bytes value must be given\r")

      service.prepend(command, key, parameters, client)

      #this is the behavior beeing tested
      expect(database.data_entry(key).body).to eq("Priscila Ruiz")

      database.delete("4123456")
    end

    it 'does not store data if the bytes value given is not a numeric value' do
      service = Service.new

      command = "prepend"
      parameters = "random"
      key = "4123456"
      database = service.database()
      client = double("client")

      database.store_data_entry("4123456", "10", "0", "13", "Priscila Ruiz", 1)

      #these 'expect' are necessary because of the server's design
      expect(client).to receive(:puts).with("CLIENT_ERROR bytes must be a numeric value\r")

      service.prepend(command, key, parameters, client)

      #this is the behavior beeing tested
      expect(database.data_entry(key).body).to eq("Priscila Ruiz")

      database.delete("4123456")
    end
  end
end
