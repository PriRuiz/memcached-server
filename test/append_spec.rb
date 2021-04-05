require_relative '../src/server'

RSpec.configure do |config|
  config.formatter = :documentation
end

describe Service do
  describe 'append' do
    describe 'adds data to an existing key after existing data' do
      before (:each) do
        service = Service.new

        command = "append"
        parameters = "10"
        @key = "4123456"
        @database = service.database()
        client = double("client")

        @database.store_data_entry("4123456", "10", "0", "13", "Priscila Ruiz", 1)

        #these 'expect' are necessary because of the server's design
        expect(client).to receive(:read).with(12).and_return("Coccinello\r\n").ordered
        expect(client).to receive(:puts).with("STORED\r").ordered

        service.append(command, @key, parameters, client)
      end

      it "updates the body" do
        expect(@database.data_entry(@key).body).to eq("Priscila Ruiz Coccinello")
      end
      it "updates the bytes" do
        expect(@database.data_entry(@key).bytes).to eq("24")
      end
      it "updates the cas_unique" do
        expect(@database.data_entry(@key).cas_unique).to eq(2)
      end
    end

    it 'does not store data when the server does not hold data for the given key' do
        service = Service.new

        command = "append"
        parameters = "10"
        key = "3123456"
        database = service.database()
        client = double("client")

        #this 'expect' is necessary because of the server's design
        expect(client).to receive(:read).with(12).and_return("Coccinello\r\n").ordered

        #this is the behavior beeing tested
        expect(client).to receive(:puts).with("CLIENT_ERROR the key does not exist\r").ordered

        service.append(command, key, parameters, client)
    end

    it 'does not store data if no key was recieved' do
      service = Service.new

      command = "append"
      key = nil
      parameters = nil
      database = service.database()
      client = double("client")

      #this is the behavior beeing tested
      expect(client).to receive(:puts).with("CLIENT_ERROR a key must be given and cannot exceed 250 characters\r").ordered

      service.append(command, key, parameters, client)
    end

    it 'does not store data if bytes value was not recieved' do
      service = Service.new

      command = "append"
      parameters = nil
      key = "4123456"
      database = service.database()
      client = double("client")

      database.store_data_entry("4123456", "10", "0", "13", "Priscila Ruiz", 1)

      #this 'expect' is necessary because of the server's design
      expect(client).to receive(:puts).with("CLIENT_ERROR bytes value must be given\r")

      service.append(command, key, parameters, client)

      #this is the behavior beeing tested
      expect(database.data_entry(key).body).to eq("Priscila Ruiz")
    end

    it 'does not store data if the bytes value given is not a numeric value' do
      service = Service.new

      command = "append"
      parameters = "random"
      key = "4123456"
      database = service.database()
      client = double("client")

      database.store_data_entry("4123456", "10", "0", "13", "Priscila Ruiz", 1)

      #this 'expect' is necessary because of the server's design
      expect(client).to receive(:puts).with("CLIENT_ERROR bytes must be a numeric value\r")

      service.append(command, key, parameters, client)

      #this is the behavior beeing tested
      expect(database.data_entry(key).body).to eq("Priscila Ruiz")

      database.delete("4123456")
    end
  end
end
