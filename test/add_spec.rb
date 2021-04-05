require_relative '../src/service'

RSpec.configure do |config|
  config.formatter = :documentation
end

describe Service do
  describe 'add' do
    describe 'stores data when empty' do
      before (:each) do
        service = Service.new

        command = "add"
        @key = "4123456"
        parameters = "10 0 13"
        @database = service.database()
        client = double("client")

        #these 'expect' are necessary because of the server's design
        expect(client).to receive(:read).with(15).and_return("Priscila Ruiz\r\n").ordered
        expect(client).to receive(:puts).with("STORED\r").ordered

        service.add(command, @key, parameters, client)
      end

      it "stores the key" do
        expect(@database.has_key?(@key)).to be(true)
      end
      it "stores the flags" do
        expect(@database.data_entry(@key).flags).to eq("10")
      end
      it "stores the exptime" do
        expect(@database.data_entry(@key).exptime).to eq("0")
      end
      it "stores the bytes" do
        expect(@database.data_entry(@key).bytes).to eq("13")
      end
      it "stores the body" do
        expect(@database.data_entry(@key).body).to eq("Priscila Ruiz")
      end
      it "stores the cas unique" do
        expect(@database.data_entry(@key).cas_unique).to eq(1)
      end
    end

    describe 'stores data when the server does not already hold data for the given key but the server is not empty' do
      before (:each) do
        service = Service.new

        command = "add"
        @key = "4123456"
        parameters = "10 0 13"
        @database = service.database()
        client = double("client")

        @database.store_data_entry("5123456", "10", "0", "10", "Juan Perez", 1)

        #these 'expect' are necessary because of the server's design
        expect(client).to receive(:read).with(15).and_return("Priscila Ruiz\r\n").ordered
        expect(client).to receive(:puts).with("STORED\r").ordered

        service.add(command, @key, parameters, client)
      end

      it "stores the key" do
        expect(@database.has_key?(@key)).to be(true)
      end
      it "stores the flags" do
        expect(@database.data_entry(@key).flags).to eq("10")
      end
      it "stores the exptime" do
        expect(@database.data_entry(@key).exptime).to eq("0")
      end
      it "stores the bytes" do
        expect(@database.data_entry(@key).bytes).to eq("13")
      end
      it "stores the body" do
        expect(@database.data_entry(@key).body).to eq("Priscila Ruiz")
      end
      it "stores the cas unique" do
        expect(@database.data_entry(@key).cas_unique).to eq(1)
      end
    end

    describe 'does not store data when the server already holds data for the given key' do
      before (:each) do
        service = Service.new

        command = "add"
        @key = "4123456"
        parameters = "10 0 10"
        @database = service.database()
        client = double("client")

        @database.store_data_entry("4123456", "10", "0", "13", "Priscila Ruiz", 1)

        #this 'expect' is necessary because of the server's design
        expect(client).to receive(:puts).with("NOT_STORED\r").ordered

        service.add(command, @key, parameters, client)
      end

      it "stores the key" do
        expect(@database.has_key?(@key)).to be(true)
      end
      it "stores the flags" do
        expect(@database.data_entry(@key).flags).to eq("10")
      end
      it "stores the exptime" do
        expect(@database.data_entry(@key).exptime).to eq("0")
      end
      it "stores the bytes" do
        expect(@database.data_entry(@key).bytes).to eq("13")
      end
      it "stores the body" do
        expect(@database.data_entry(@key).body).to eq("Priscila Ruiz")
      end
      it "stores the cas unique" do
        expect(@database.data_entry(@key).cas_unique).to eq(1)
      end
    end

    it 'does not store data if no key was recieved' do
      service = Service.new

      command = "add"
      key = nil
      parameters = nil
      database = service.database()
      client = double("client")

      #this 'expect' is necessary because of the server's design
      expect(client).to receive(:puts).with("CLIENT_ERROR a key must be given and cannot exceed 250 characters\r")

      service.add(command, key, parameters, client)

      expect(database.is_empty?).to eq(true)
    end

    it 'does not store data if flag value was not recieved' do
      service = Service.new

      command = "add"
      key = "4123456"
      parameters = nil
      database = service.database()
      client = double("client")

      #this 'expect' is necessary because of the server's design
      expect(client).to receive(:puts).with("CLIENT_ERROR some parameters were not given\r")

      service.add(command, key, parameters, client)

      #this is the behavior beeing tested
      expect(database.is_empty?).to eq(true)
    end

    it 'does not store data if exptime value was not recieved' do
      service = Service.new

      command = "add"
      key = "4123456"
      parameters = "10"
      database = service.database()
      client = double("client")

      #this 'expect' is necessary because of the server's design
      expect(client).to receive(:puts).with("CLIENT_ERROR some parameters were not given\r")

      service.add(command, key, parameters, client)

      #this is the behavior beeing tested
      expect(database.is_empty?).to eq(true)
    end

    it 'does not store data if bytes value was not recieved' do
      service = Service.new

      command = "add"
      key = "4123456"
      parameters = "10 0"
      database = service.database()
      client = double("client")

      #this 'expect' is necessary because of the server's design
      expect(client).to receive(:puts).with("CLIENT_ERROR some parameters were not given\r")

      service.add(command, key, parameters, client)

      #this is the behavior beeing tested
      expect(database.is_empty?).to eq(true)
    end

    it 'does not store data if the flag given is not an unsigned integer' do
      service = Service.new

      command = "add"
      key = "4123456"
      parameters = "random 0 10"
      database = service.database()
      client = double("client")

      #this 'expect' is necessary because of the server's design
      expect(client).to receive(:puts).with("CLIENT_ERROR flags must be a 16-bit unsigned integer\r")

      service.add(command, key, parameters, client)

      #this is the behavior beeing tested
      expect(database.is_empty?).to eq(true)
    end

    it 'does not store data if the exptime given is not Unix Time' do
      service = Service.new

      command = "add"
      key = "4123456"
      parameters = "10 random 10"
      database = service.database()
      client = double("client")

      #this 'expect' is necessary because of the server's design
      expect(client).to receive(:puts).with("CLIENT_ERROR exptime must be Unix Time\r")

      service.add(command, key, parameters, client)

      #this is the behavior beeing tested
      expect(database.is_empty?).to eq(true)
    end

    it 'does not store data if the bytes value given is not a numeric value' do
      service = Service.new

      command = "add"
      key = "4123456"
      parameters = "10 0 random"
      database = service.database()
      client = double("client")

      #this 'expect' is necessary because of the server's design
      expect(client).to receive(:puts).with("CLIENT_ERROR bytes must be a numeric value\r")

      service.add(command, key, parameters, client)

      #this is the behavior beeing tested
      expect(database.is_empty?).to eq(true)
    end

    it 'does not store data if the data block does not end with \r\n' do
      service = Service.new

      command = "add"
      key = "4123456"
      parameters = "10 0 11"
      database = service.database()
      client = double("client")

      #these 'expect' are necessary because of the server's design
      expect(client).to receive(:read).with(13).and_return("Priscila Ruiz").ordered
      expect(client).to receive(:puts).with('Data blocks must end with \r\n'"\r").ordered

      service.add(command, key, parameters, client)

      #this is the behavior beeing tested
      expect(database.is_empty?).to eq(true)
    end
  end
end
