require_relative 'server'

RSpec.configure do |config|
  config.formatter = :documentation
end

describe Server do
  server = Server.new

  describe 'handleClient' do
    it 'calls method set if the passed command is set' do
      command = "set"
      key = "4123456"
      parameters = "10 0 13"
      data = {}
      client = double("client")

      expect(client).to receive(:puts).with("Welcome!\r").ordered
      expect(client).to receive(:gets).and_return("set 4123456 10 0 13").ordered
      expect(server).to receive(:set).with(command, key, parameters, data, client).ordered
      expect(client).to receive(:gets).and_return(NIL).ordered

      server.handleClient(data, client)
    end

    it 'calls method add if the passed command is add' do
      command = "add"
      key = "4123456"
      parameters = "10 0 13"
      data = {}
      client = double("client")

      expect(client).to receive(:puts).with("Welcome!\r").ordered
      expect(client).to receive(:gets).and_return("add 4123456 10 0 13").ordered
      expect(server).to receive(:add).with(command, key, parameters, data, client).ordered
      expect(client).to receive(:gets).and_return(NIL).ordered

      server.handleClient(data, client)
    end

    it 'calls method replace if the passed command is replace' do
      command = "replace"
      key = "4123456"
      parameters = "10 0 13"
      data = {}
      client = double("client")

      expect(client).to receive(:puts).with("Welcome!\r").ordered
      expect(client).to receive(:gets).and_return("replace 4123456 10 0 13").ordered
      expect(server).to receive(:replace).with(command, key, parameters, data, client).ordered
      expect(client).to receive(:gets).and_return(NIL).ordered

      server.handleClient(data, client)
    end

    it 'calls method append if the passed command is append' do
      command = "append"
      key = "4123456"
      parameters = nil
      data = {}
      client = double("client")

      expect(client).to receive(:puts).with("Welcome!\r").ordered
      expect(client).to receive(:gets).and_return("append 4123456").ordered
      expect(server).to receive(:append).with(command, key, parameters, data, client).ordered
      expect(client).to receive(:gets).and_return(NIL).ordered

      server.handleClient(data, client)
    end

    it 'calls method prepend if the passed command is prepend' do
      command = "prepend"
      key = "4123456"
      parameters = nil
      data = {}
      client = double("client")

      expect(client).to receive(:puts).with("Welcome!\r").ordered
      expect(client).to receive(:gets).and_return("prepend 4123456").ordered
      expect(server).to receive(:prepend).with(command, key, parameters, data, client).ordered
      expect(client).to receive(:gets).and_return(NIL).ordered

      server.handleClient(data, client)
    end

    it 'calls method cas if the passed command is cas' do
      command = "cas"
      key = "4123456"
      parameters = "10 0 13 1"
      data = {}
      client = double("client")

      expect(client).to receive(:puts).with("Welcome!\r").ordered
      expect(client).to receive(:gets).and_return("cas 4123456 10 0 13 1").ordered
      expect(server).to receive(:cas).with(command, key, parameters, data, client).ordered
      expect(client).to receive(:gets).and_return(NIL).ordered

      server.handleClient(data, client)
    end

    it 'calls method get if the passed command is get' do
      command = "get"
      key = "4123456"
      parameters = nil
      data = {}
      client = double("client")

      expect(client).to receive(:puts).with("Welcome!\r").ordered
      expect(client).to receive(:gets).and_return("get 4123456").ordered
      expect(server).to receive(:get).with(command, key, parameters, data, client).ordered
      expect(client).to receive(:gets).and_return(NIL).ordered

      server.handleClient(data, client)
    end

    it 'calls method gets if the passed command is gets' do
      command = "gets"
      key = "4123456"
      parameters = nil
      data = {}
      client = double("client")

      expect(client).to receive(:puts).with("Welcome!\r").ordered
      expect(client).to receive(:gets).and_return("gets 4123456").ordered
      expect(server).to receive(:gets).with(command, key, parameters, data, client).ordered
      expect(client).to receive(:gets).and_return(NIL).ordered

      server.handleClient(data, client)
    end

    it 'returns error message if the passed command does not exist' do
      command = "random"
      key = nil
      parameters = nil
      data = {}
      client = double("client")

      expect(client).to receive(:puts).with("Welcome!\r").ordered
      expect(client).to receive(:gets).and_return("random").ordered
      expect(client).to receive(:puts).with("ERROR\r").ordered
      expect(client).to receive(:gets).and_return(NIL).ordered

      server.handleClient(data, client)
    end
  end

  describe 'set' do
    it 'stores data when empty' do
      command = "set"
      key = "4123456"
      parameters = "10 0 13"
      data = {}
      client = double("client")

      expect(client).to receive(:read).with(15).and_return("Priscila Ruiz\r\n").ordered
      expect(client).to receive(:puts).with("STORED\r").ordered

      server.set(command, key, parameters, data, client)

      expect(data.has_key? "4123456").to be(true)
      expect(data["4123456"]["flags"]). to eq("10")
      expect(data["4123456"]["exptime"]).to eq("0")
      expect(data["4123456"]["bytes"]).to eq("13")
      expect(data["4123456"]["body"]).to eq("Priscila Ruiz")
      expect(data["4123456"]["cas_unique"]).to eq(1)
    end

    it 'stores data when the server does not already hold data for the given key but the server is not empty' do
      command = "set"
      key = "4123456"
      parameters = "10 0 13"
      data = {}
      client = double("client")

      bloque = {}
      bloque["flags"] = "10"
      bloque["exptime"] = "0"
      bloque["bytes"] = "10"
      bloque["body"] = "Juan Perez"
      bloque["cas_unique"] = 1
      data["5123456"] = bloque

      expect(client).to receive(:read).with(15).and_return("Priscila Ruiz\r\n").ordered
      expect(client).to receive(:puts).with("STORED\r").ordered

      server.set(command, key, parameters, data, client)

      expect(data.has_key? "4123456").to be(true)
      expect(data["4123456"]["flags"]). to eq("10")
      expect(data["4123456"]["exptime"]).to eq("0")
      expect(data["4123456"]["bytes"]).to eq("13")
      expect(data["4123456"]["body"]).to eq("Priscila Ruiz")
      expect(data["4123456"]["cas_unique"]).to eq(1)
    end

    it 'stores data when the server already holds data for the given key' do
      command = "set"
      key = "4123456"
      parameters = "10 0 10"
      data = {}
      client = double("client")

      bloque = {}
      bloque["flags"] = "10"
      bloque["exptime"] = "0"
      bloque["bytes"] = "13"
      bloque["body"] = "Priscila Ruiz"
      bloque["cas_unique"] = 1
      data["4123456"] = bloque

      expect(client).to receive(:read).with(12).and_return("Juan Perez\r\n").ordered
      expect(client).to receive(:puts).with("STORED\r").ordered

      server.set(command, key, parameters, data, client)

      expect(data.has_key? "4123456").to be(true)
      expect(data["4123456"]["flags"]). to eq("10")
      expect(data["4123456"]["exptime"]).to eq("0")
      expect(data["4123456"]["bytes"]).to eq("10")
      expect(data["4123456"]["body"]).to eq("Juan Perez")
      expect(data["4123456"]["cas_unique"]).to eq(2)
    end

    it 'does not store data if no key was recieved' do
      command = "set"
      key = nil
      parameters = nil
      data = {}
      client = double("client")

      expect(client).to receive(:puts).with("CLIENT_ERROR a key must be given and cannot exceed 250 characters\r")

      server.set(command, key, parameters, data, client)

      expect(data).to eq({})
    end

    it 'does not store data if flag value was not recieved' do
      command = "set"
      key = "4123456"
      parameters = nil
      data = {}
      client = double("client")

      expect(client).to receive(:puts).with("CLIENT_ERROR some parameters were not given\r")

      server.set(command, key, parameters, data, client)

      expect(data).to eq({})
    end

    it 'does not store data if exptime value was not recieved' do
      command = "set"
      key = "4123456"
      parameters = "10"
      data = {}
      client = double("client")

      expect(client).to receive(:puts).with("CLIENT_ERROR some parameters were not given\r")

      server.set(command, key, parameters, data, client)

      expect(data).to eq({})
    end

    it 'does not store data if bytes value was not recieved' do
      command = "set"
      key = "4123456"
      parameters = "10 0"
      data = {}
      client = double("client")

      expect(client).to receive(:puts).with("CLIENT_ERROR some parameters were not given\r")

      server.set(command, key, parameters, data, client)

      expect(data).to eq({})
    end

    it 'does not store data if the flag given is not an unsigned integer' do
      command = "set"
      key = "4123456"
      parameters = "random 0 10"
      data = {}
      client = double("client")

      expect(client).to receive(:puts).with("CLIENT_ERROR flags must be a 16-bit unsigned integer\r")

      server.set(command, key, parameters, data, client)

      expect(data).to eq({})
    end

    it 'does not store data if the exptime given is not Unix Time' do
      command = "set"
      key = "4123456"
      parameters = "10 random 10"
      data = {}
      client = double("client")

      expect(client).to receive(:puts).with("CLIENT_ERROR exptime must be Unix Time\r")

      server.set(command, key, parameters, data, client)

      expect(data).to eq({})
    end

    it 'does not store data if the bytes value given is not a numeric value' do
      command = "set"
      key = "4123456"
      parameters = "10 0 random"
      data = {}
      client = double("client")

      expect(client).to receive(:puts).with("CLIENT_ERROR bytes must be a numeric value\r")

      server.set(command, key, parameters, data, client)

      expect(data).to eq({})
    end

    it 'does not store data if the data block does not end with \r\n' do
      command = "set"
      key = "4123456"
      parameters = "10 0 11"
      data = {}
      client = double("client")

      expect(client).to receive(:read).with(13).and_return("Priscila Ruiz").ordered
      expect(client).to receive(:puts).with('Data blocks must end with \r\n'"\r").ordered

      server.set(command, key, parameters, data, client)

      expect(data).to eq({})
    end
  end

  describe 'add' do
    it 'stores data when empty' do
      command = "add"
      key = "4123456"
      parameters = "10 0 13"
      data = {}
      client = double("client")

      expect(client).to receive(:read).with(15).and_return("Priscila Ruiz\r\n").ordered
      expect(client).to receive(:puts).with("STORED\r").ordered

      server.add(command, key, parameters, data, client)

      expect(data.has_key? "4123456").to be(true)
      expect(data["4123456"]["flags"]). to eq("10")
      expect(data["4123456"]["exptime"]).to eq("0")
      expect(data["4123456"]["bytes"]).to eq("13")
      expect(data["4123456"]["body"]).to eq("Priscila Ruiz")
      expect(data["4123456"]["cas_unique"]).to eq(1)
    end

    it 'stores data when the server does not already hold data for the given key but the server is not empty' do
      command = "add"
      key = "4123456"
      parameters = "10 0 13"
      data = {}
      client = double("client")

      bloque = {}
      bloque["flags"] = "10"
      bloque["exptime"] = "0"
      bloque["bytes"] = "10"
      bloque["body"] = "Juan Perez"
      bloque["cas_unique"] = 1
      data["5123456"] = bloque

      expect(client).to receive(:read).with(15).and_return("Priscila Ruiz\r\n").ordered
      expect(client).to receive(:puts).with("STORED\r").ordered

      server.add(command, key, parameters, data, client)

      expect(data.has_key? "4123456").to be(true)
      expect(data["4123456"]["flags"]). to eq("10")
      expect(data["4123456"]["exptime"]).to eq("0")
      expect(data["4123456"]["bytes"]).to eq("13")
      expect(data["4123456"]["body"]).to eq("Priscila Ruiz")
      expect(data["4123456"]["cas_unique"]).to eq(1)
    end

    it 'does not store data when the server already holds data for the given key' do
      command = "add"
      key = "4123456"
      parameters = "10 0 10"
      data = {}
      client = double("client")

      bloque = {}
      bloque["flags"] = "10"
      bloque["exptime"] = "0"
      bloque["bytes"] = "13"
      bloque["body"] = "Priscila Ruiz"
      bloque["cas_unique"] = 1
      data["4123456"] = bloque

      expect(client).to receive(:puts).with("NOT_STORED\r").ordered

      server.add(command, key, parameters, data, client)

      expect(data.has_key? "4123456").to be(true)
      expect(data["4123456"]["flags"]). to eq("10")
      expect(data["4123456"]["exptime"]).to eq("0")
      expect(data["4123456"]["bytes"]).to eq("13")
      expect(data["4123456"]["body"]).to eq("Priscila Ruiz")
      expect(data["4123456"]["cas_unique"]).to eq(1)
    end

    it 'does not store data if no key was recieved' do
      command = "add"
      key = nil
      parameters = nil
      data = {}
      client = double("client")

      expect(client).to receive(:puts).with("CLIENT_ERROR a key must be given and cannot exceed 250 characters\r")

      server.add(command, key, parameters, data, client)

      expect(data).to eq({})
    end

    it 'does not store data if flag value was not recieved' do
      command = "add"
      key = "4123456"
      parameters = nil
      data = {}
      client = double("client")

      expect(client).to receive(:puts).with("CLIENT_ERROR some parameters were not given\r")

      server.add(command, key, parameters, data, client)

      expect(data).to eq({})
    end

    it 'does not store data if exptime value was not recieved' do
      command = "add"
      key = "4123456"
      parameters = "10"
      data = {}
      client = double("client")

      expect(client).to receive(:puts).with("CLIENT_ERROR some parameters were not given\r")

      server.add(command, key, parameters, data, client)

      expect(data).to eq({})
    end

    it 'does not store data if bytes value was not recieved' do
      command = "add"
      key = "4123456"
      parameters = "10 0"
      data = {}
      client = double("client")

      expect(client).to receive(:puts).with("CLIENT_ERROR some parameters were not given\r")

      server.add(command, key, parameters, data, client)

      expect(data).to eq({})
    end

    it 'does not store data if the flag given is not an unsigned integer' do
      command = "add"
      key = "4123456"
      parameters = "random 0 10"
      data = {}
      client = double("client")

      expect(client).to receive(:puts).with("CLIENT_ERROR flags must be a 16-bit unsigned integer\r")

      server.add(command, key, parameters, data, client)

      expect(data).to eq({})
    end

    it 'does not store data if the exptime given is not Unix Time' do
      command = "add"
      key = "4123456"
      parameters = "10 random 10"
      data = {}
      client = double("client")

      expect(client).to receive(:puts).with("CLIENT_ERROR exptime must be Unix Time\r")

      server.add(command, key, parameters, data, client)

      expect(data).to eq({})
    end

    it 'does not store data if the bytes value given is not a numeric value' do
      command = "add"
      key = "4123456"
      parameters = "10 0 random"
      data = {}
      client = double("client")

      expect(client).to receive(:puts).with("CLIENT_ERROR bytes must be a numeric value\r")

      server.add(command, key, parameters, data, client)

      expect(data).to eq({})
    end

    it 'does not store data if the data block does not end with \r\n' do
      command = "add"
      key = "4123456"
      parameters = "10 0 11"
      data = {}
      client = double("client")

      expect(client).to receive(:read).with(13).and_return("Priscila Ruiz").ordered
      expect(client).to receive(:puts).with('Data blocks must end with \r\n'"\r").ordered

      server.add(command, key, parameters, data, client)

      expect(data).to eq({})
    end
  end

  describe 'replace' do
    it 'does not store data when empty' do
      command = "replace"
      key = "4123456"
      parameters = "10 0 13"
      data = {}
      client = double("client")

      expect(client).to receive(:puts).with("NOT_STORED\r").ordered

      server.replace(command, key, parameters, data, client)

      expect(data.has_key? "4123456").to be(false)
    end

    it 'does not store data when the server does not already hold data for the given key but the server is not empty' do
      command = "replace"
      key = "4123456"
      parameters = "10 0 13"
      data = {}
      client = double("client")

      bloque = {}
      bloque["flags"] = "10"
      bloque["exptime"] = "0"
      bloque["bytes"] = "10"
      bloque["body"] = "Juan Perez"
      bloque["cas_unique"] = 1
      data["5123456"] = bloque

      expect(client).to receive(:puts).with("NOT_STORED\r").ordered

      server.replace(command, key, parameters, data, client)

      expect(data.has_key? "4123456").to be(false)
    end

    it 'stores data when the server already holds data for the given key' do
      command = "replace"
      key = "4123456"
      parameters = "10 0 10"
      data = {}
      client = double("client")

      bloque = {}
      bloque["flags"] = "10"
      bloque["exptime"] = "0"
      bloque["bytes"] = "13"
      bloque["body"] = "Priscila Ruiz"
      bloque["cas_unique"] = 1
      data["4123456"] = bloque

      expect(client).to receive(:read).with(12).and_return("Juan Perez\r\n").ordered
      expect(client).to receive(:puts).with("STORED\r").ordered

      server.replace(command, key, parameters, data, client)

      expect(data.has_key? "4123456").to be(true)
      expect(data["4123456"]["flags"]). to eq("10")
      expect(data["4123456"]["exptime"]).to eq("0")
      expect(data["4123456"]["bytes"]).to eq("10")
      expect(data["4123456"]["body"]).to eq("Juan Perez")
      expect(data["4123456"]["cas_unique"]).to eq(2)
    end

    it 'does not store data if no key was recieved' do
      command = "replace"
      key = nil
      parameters = nil
      data = {}
      client = double("client")

      bloque = {}
      bloque["flags"] = "10"
      bloque["exptime"] = "0"
      bloque["bytes"] = "13"
      bloque["body"] = "Priscila Ruiz"
      bloque["cas_unique"] = 1
      data["4123456"] = bloque

      expect(client).to receive(:puts).with("CLIENT_ERROR a key must be given and cannot exceed 250 characters\r")

      server.replace(command, key, parameters, data, client)

      expect(data).to eq("4123456" => {"flags"=>"10", "exptime"=>"0", "bytes"=>"13", "body"=>"Priscila Ruiz", "cas_unique"=>1})
    end

    it 'does not store data if flag value was not recieved' do
      command = "replace"
      key = "4123456"
      parameters = nil
      data = {}
      client = double("client")

      bloque = {}
      bloque["flags"] = "10"
      bloque["exptime"] = "0"
      bloque["bytes"] = "13"
      bloque["body"] = "Priscila Ruiz"
      bloque["cas_unique"] = 1
      data["4123456"] = bloque

      expect(client).to receive(:puts).with("CLIENT_ERROR some parameters were not given\r")

      server.replace(command, key, parameters, data, client)

      expect(data).to eq("4123456" => {"flags"=>"10", "exptime"=>"0", "bytes"=>"13", "body"=>"Priscila Ruiz", "cas_unique"=>1})
    end

    it 'does not store data if exptime value was not recieved' do
      command = "replace"
      key = "4123456"
      parameters = "10"
      data = {}
      client = double("client")

      bloque = {}
      bloque["flags"] = "10"
      bloque["exptime"] = "0"
      bloque["bytes"] = "13"
      bloque["body"] = "Priscila Ruiz"
      bloque["cas_unique"] = 1
      data["4123456"] = bloque

      expect(client).to receive(:puts).with("CLIENT_ERROR some parameters were not given\r")

      server.replace(command, key, parameters, data, client)

      expect(data).to eq("4123456" => {"flags"=>"10", "exptime"=>"0", "bytes"=>"13", "body"=>"Priscila Ruiz", "cas_unique"=>1})
    end

    it 'does not store data if bytes value was not recieved' do
      command = "replace"
      key = "4123456"
      parameters = "10 0"
      data = {}
      client = double("client")

      bloque = {}
      bloque["flags"] = "10"
      bloque["exptime"] = "0"
      bloque["bytes"] = "13"
      bloque["body"] = "Priscila Ruiz"
      bloque["cas_unique"] = 1
      data["4123456"] = bloque

      expect(client).to receive(:puts).with("CLIENT_ERROR some parameters were not given\r")

      server.replace(command, key, parameters, data, client)

      expect(data).to eq("4123456" => {"flags"=>"10", "exptime"=>"0", "bytes"=>"13", "body"=>"Priscila Ruiz", "cas_unique"=>1})
    end

    it 'does not store data if the flag given is not an unsigned integer' do
      command = "replace"
      key = "4123456"
      parameters = "random 0 10"
      data = {}
      client = double("client")

      bloque = {}
      bloque["flags"] = "10"
      bloque["exptime"] = "0"
      bloque["bytes"] = "13"
      bloque["body"] = "Priscila Ruiz"
      bloque["cas_unique"] = 1
      data["4123456"] = bloque

      expect(client).to receive(:puts).with("CLIENT_ERROR flags must be a 16-bit unsigned integer\r")

      server.replace(command, key, parameters, data, client)

      expect(data).to eq("4123456" => {"flags"=>"10", "exptime"=>"0", "bytes"=>"13", "body"=>"Priscila Ruiz", "cas_unique"=>1})
    end

    it 'does not store data if the exptime given is not Unix Time' do
      command = "replace"
      key = "4123456"
      parameters = "10 random 10"
      data = {}
      client = double("client")

      bloque = {}
      bloque["flags"] = "10"
      bloque["exptime"] = "0"
      bloque["bytes"] = "13"
      bloque["body"] = "Priscila Ruiz"
      bloque["cas_unique"] = 1
      data["4123456"] = bloque

      expect(client).to receive(:puts).with("CLIENT_ERROR exptime must be Unix Time\r")

      server.replace(command, key, parameters, data, client)

      expect(data).to eq("4123456" => {"flags"=>"10", "exptime"=>"0", "bytes"=>"13", "body"=>"Priscila Ruiz", "cas_unique"=>1})
    end

    it 'does not store data if the bytes value given is not a numeric value' do
      command = "replace"
      key = "4123456"
      parameters = "10 0 random"
      data = {}
      client = double("client")

      bloque = {}
      bloque["flags"] = "10"
      bloque["exptime"] = "0"
      bloque["bytes"] = "13"
      bloque["body"] = "Priscila Ruiz"
      bloque["cas_unique"] = 1
      data["4123456"] = bloque

      expect(client).to receive(:puts).with("CLIENT_ERROR bytes must be a numeric value\r")

      server.replace(command, key, parameters, data, client)

      expect(data).to eq("4123456" => {"flags"=>"10", "exptime"=>"0", "bytes"=>"13", "body"=>"Priscila Ruiz", "cas_unique"=>1})
    end

    it 'does not store data if the data block does not end with \r\n' do
      command = "replace"
      key = "4123456"
      parameters = "10 0 11"
      data = {}
      client = double("client")

      bloque = {}
      bloque["flags"] = "10"
      bloque["exptime"] = "0"
      bloque["bytes"] = "13"
      bloque["body"] = "Priscila Ruiz"
      bloque["cas_unique"] = 1
      data["4123456"] = bloque

      expect(client).to receive(:read).with(13).and_return("Priscila Ruiz").ordered
      expect(client).to receive(:puts).with('Data blocks must end with \r\n'"\r").ordered

      server.replace(command, key, parameters, data, client)

      expect(data).to eq("4123456" => {"flags"=>"10", "exptime"=>"0", "bytes"=>"13", "body"=>"Priscila Ruiz", "cas_unique"=>1})
    end
  end

  describe 'append' do
    it 'adds data to an existing key after existing data' do
      command = "append"
      parameters = "10"
      key = "4123456"
      data = {}
      client = double("client")

      bloque = {}
      bloque["flags"] = "10"
      bloque["exptime"] = "0"
      bloque["bytes"] = "13"
      bloque["body"] = "Priscila Ruiz"
      bloque["cas_unique"] = 1
      data["4123456"] = bloque

      expect(client).to receive(:read).with(12).and_return("Coccinello\r\n").ordered
      expect(client).to receive(:puts).with("STORED\r").ordered

      server.append(command, key, parameters, data, client)

      expect(data["4123456"]["body"]).to eq("Priscila Ruiz Coccinello")
      expect(data["4123456"]["bytes"]).to eq("24")
      expect(data["4123456"]["cas_unique"]).to eq(2)

    end

    it 'does not store data when the server does not hold data for the given key' do
      command = "append"
      parameters = "10"
      key = "3123456"
      data = {}
      client = double("client")

      bloque = {}
      bloque["flags"] = "10"
      bloque["exptime"] = "0"
      bloque["bytes"] = "13"
      bloque["body"] = "Priscila Ruiz"
      bloque["cas_unique"] = 1
      data["4123456"] = bloque

      expect(client).to receive(:read).with(12).and_return("Coccinello\r\n").ordered
      expect(client).to receive(:puts).with("CLIENT_ERROR the key does not exist\r").ordered

      server.append(command, key, parameters, data, client)

      expect(data).to eq("4123456" => {"flags"=>"10", "exptime"=>"0", "bytes"=>"13", "body"=>"Priscila Ruiz", "cas_unique"=>1})
    end

    it 'does not store data if no key was recieved' do
      command = "append"
      key = nil
      parameters = nil
      data = {}
      client = double("client")

      bloque = {}
      bloque["flags"] = "10"
      bloque["exptime"] = "0"
      bloque["bytes"] = "13"
      bloque["body"] = "Priscila Ruiz"
      bloque["cas_unique"] = 1
      data["4123456"] = bloque

      expect(client).to receive(:puts).with("CLIENT_ERROR a key must be given and cannot exceed 250 characters\r").ordered

      server.append(command, key, parameters, data, client)

      expect(data).to eq("4123456" => {"flags"=>"10", "exptime"=>"0", "bytes"=>"13", "body"=>"Priscila Ruiz", "cas_unique"=>1})
    end

    it 'does not store data if bytes value was not recieved' do
      command = "append"
      parameters = nil
      key = "4123456"
      data = {}
      client = double("client")

      bloque = {}
      bloque["flags"] = "10"
      bloque["exptime"] = "0"
      bloque["bytes"] = "13"
      bloque["body"] = "Priscila Ruiz"
      bloque["cas_unique"] = 1
      data["4123456"] = bloque

      expect(client).to receive(:puts).with("CLIENT_ERROR bytes value must be given\r")

      server.append(command, key, parameters, data, client)

      expect(data["4123456"]["body"]).to eq("Priscila Ruiz")
    end

    it 'does not store data if the bytes value given is not a numeric value' do
      command = "append"
      parameters = "random"
      key = "4123456"
      data = {}
      client = double("client")

      bloque = {}
      bloque["flags"] = "10"
      bloque["exptime"] = "0"
      bloque["bytes"] = "13"
      bloque["body"] = "Priscila Ruiz"
      bloque["cas_unique"] = 1
      data["4123456"] = bloque

      expect(client).to receive(:puts).with("CLIENT_ERROR bytes must be a numeric value\r")

      server.append(command, key, parameters, data, client)

      expect(data["4123456"]["body"]).to eq("Priscila Ruiz")
    end
  end

  describe 'prepend' do
    it 'adds data to an existing key after existing data' do
      command = "prepend"
      parameters = "7"
      key = "4123456"
      data = {}
      client = double("client")

      bloque = {}
      bloque["flags"] = "10"
      bloque["exptime"] = "0"
      bloque["bytes"] = "13"
      bloque["body"] = "Priscila Ruiz"
      bloque["cas_unique"] = 1
      data["4123456"] = bloque

      expect(client).to receive(:read).with(9).and_return("Fabiana\r\n").ordered
      expect(client).to receive(:puts).with("STORED\r").ordered

      server.prepend(command, key, parameters, data, client)

      expect(data["4123456"]["body"]).to eq("Fabiana Priscila Ruiz")
      expect(data["4123456"]["bytes"]).to eq("21")
      expect(data["4123456"]["cas_unique"]).to eq(2)

    end

    it 'does not store data when the server does not hold data for the given key' do
      command = "prepend"
      parameters = "7"
      key = "3123456"
      data = {}
      client = double("client")

      bloque = {}
      bloque["flags"] = "10"
      bloque["exptime"] = "0"
      bloque["bytes"] = "13"
      bloque["body"] = "Priscila Ruiz"
      bloque["cas_unique"] = 1
      data["4123456"] = bloque

      expect(client).to receive(:read).with(9).and_return("Fabiana\r\n").ordered
      expect(client).to receive(:puts).with("CLIENT_ERROR the key does not exist\r").ordered

      server.prepend(command, key, parameters, data, client)

      expect(data).to eq("4123456" => {"flags"=>"10", "exptime"=>"0", "bytes"=>"13", "body"=>"Priscila Ruiz", "cas_unique"=>1})
    end

    it 'does not store data if no key was recieved' do
      command = "prepend"
      key = nil
      parameters = nil
      data = {}
      client = double("client")

      bloque = {}
      bloque["flags"] = "10"
      bloque["exptime"] = "0"
      bloque["bytes"] = "13"
      bloque["body"] = "Priscila Ruiz"
      bloque["cas_unique"] = 1
      data["4123456"] = bloque

      expect(client).to receive(:puts).with("CLIENT_ERROR a key must be given and cannot exceed 250 characters\r").ordered

      server.prepend(command, key, parameters, data, client)

      expect(data).to eq("4123456" => {"flags"=>"10", "exptime"=>"0", "bytes"=>"13", "body"=>"Priscila Ruiz", "cas_unique"=>1})
    end

    it 'does not store data if bytes value was not recieved' do
      command = "prepend"
      parameters = nil
      key = "4123456"
      data = {}
      client = double("client")

      bloque = {}
      bloque["flags"] = "10"
      bloque["exptime"] = "0"
      bloque["bytes"] = "13"
      bloque["body"] = "Priscila Ruiz"
      bloque["cas_unique"] = 1
      data["4123456"] = bloque

      expect(client).to receive(:puts).with("CLIENT_ERROR bytes value must be given\r")

      server.prepend(command, key, parameters, data, client)

      expect(data["4123456"]["body"]).to eq("Priscila Ruiz")
    end

    it 'does not store data if the bytes value given is not a numeric value' do
      command = "prepend"
      parameters = "random"
      key = "4123456"
      data = {}
      client = double("client")

      bloque = {}
      bloque["flags"] = "10"
      bloque["exptime"] = "0"
      bloque["bytes"] = "13"
      bloque["body"] = "Priscila Ruiz"
      bloque["cas_unique"] = 1
      data["4123456"] = bloque

      expect(client).to receive(:puts).with("CLIENT_ERROR bytes must be a numeric value\r")

      server.prepend(command, key, parameters, data, client)

      expect(data["4123456"]["body"]).to eq("Priscila Ruiz")
    end
  end

  describe 'cas' do
    it 'stores data if the item has not been updated since last fetched by the client' do
      command = "cas"
      key = "4123456"
      parameters = "10 0 24 1"
      data = {}
      client = double("client")

      bloque = {}
      bloque["flags"] = "10"
      bloque["exptime"] = "0"
      bloque["bytes"] = "13"
      bloque["body"] = "Priscila Ruiz"
      bloque["cas_unique"] = 1
      data["4123456"] = bloque

      expect(client).to receive(:read).with(26).and_return("Priscila Ruiz Coccinello\r\n").ordered
      expect(client).to receive(:puts).with("STORED\r").ordered

      server.cas(command, key, parameters, data, client)

      expect(data.has_key? "4123456").to be(true)
      expect(data["4123456"]["flags"]). to eq("10")
      expect(data["4123456"]["exptime"]).to eq("0")
      expect(data["4123456"]["bytes"]).to eq("24")
      expect(data["4123456"]["body"]).to eq("Priscila Ruiz Coccinello")
      expect(data["4123456"]["cas_unique"]).to eq(2)
    end

    it 'does not store data if the item does not exist' do
      command = "cas"
      key = "4123456"
      parameters = "10 0 13 1"
      data = {}
      client = double("client")

      expect(client).to receive(:puts).with("NOT_FOUND\r")

      server.cas(command, key, parameters, data, client)
    end

    it 'does not store data if the item has been updated since last fetched by the client' do
      command = "cas"
      key = "4123456"
      parameters = "10 0 24 1"
      data = {}
      client = double("client")

      bloque = {}
      bloque["flags"] = "10"
      bloque["exptime"] = "0"
      bloque["bytes"] = "13"
      bloque["body"] = "Priscila Ruiz"
      bloque["cas_unique"] = 2
      data["4123456"] = bloque

      expect(client).to receive(:puts).with("EXISTS\r")

      server.cas(command, key, parameters, data, client)
    end

    it 'does not store data if no key was recieved' do
      command = "cas"
      key = nil
      parameters = nil
      data = {}
      client = double("client")

      expect(client).to receive(:puts).with("CLIENT_ERROR a key must be given and cannot exceed 250 characters\r")

      server.set(command, key, parameters, data, client)

      expect(data).to eq({})
    end

    it 'does not store data if flag value was not recieved' do
      command = "set"
      key = "4123456"
      parameters = nil
      data = {}
      client = double("client")

      expect(client).to receive(:puts).with("CLIENT_ERROR some parameters were not given\r")

      server.set(command, key, parameters, data, client)

      expect(data).to eq({})
    end

    it 'does not store data if exptime value was not recieved' do
      command = "set"
      key = "4123456"
      parameters = "10"
      data = {}
      client = double("client")

      expect(client).to receive(:puts).with("CLIENT_ERROR some parameters were not given\r")

      server.set(command, key, parameters, data, client)

      expect(data).to eq({})
    end

    it 'does not store data if bytes value was not recieved' do
      command = "set"
      key = "4123456"
      parameters = "10 0"
      data = {}
      client = double("client")

      expect(client).to receive(:puts).with("CLIENT_ERROR some parameters were not given\r")

      server.set(command, key, parameters, data, client)

      expect(data).to eq({})
    end

    it 'does not store data if the cas unique key was not recieved' do
      command = "cas"
      key = "4123456"
      parameters = "10 0 13"
      data = {}
      client = double("client")

      expect(client).to receive(:puts).with("CLIENT_ERROR cas unique key must be given\r")

      server.set(command, key, parameters, data, client)

      expect(data).to eq({})
    end

    it 'does not store data if the flag given is not an unsigned integer' do
      command = "set"
      key = "4123456"
      parameters = "random 0 10"
      data = {}
      client = double("client")

      expect(client).to receive(:puts).with("CLIENT_ERROR flags must be a 16-bit unsigned integer\r")

      server.set(command, key, parameters, data, client)

      expect(data).to eq({})
    end

    it 'does not store data if the exptime given is not Unix Time' do
      command = "set"
      key = "4123456"
      parameters = "10 random 10"
      data = {}
      client = double("client")

      expect(client).to receive(:puts).with("CLIENT_ERROR exptime must be Unix Time\r")

      server.set(command, key, parameters, data, client)

      expect(data).to eq({})
    end

    it 'does not store data if the bytes value given is not a numeric value' do
      command = "set"
      key = "4123456"
      parameters = "10 0 random"
      data = {}
      client = double("client")

      expect(client).to receive(:puts).with("CLIENT_ERROR bytes must be a numeric value\r")

      server.set(command, key, parameters, data, client)

      expect(data).to eq({})
    end

    it 'does not store data if the unique_key given is not a numeric value' do
      command = "cas"
      key = "4123456"
      parameters = "10 0 10 random"
      data = {}
      client = double("client")

      expect(client).to receive(:puts).with("CLIENT_ERROR cas unique key must be a numeric value\r")

      server.set(command, key, parameters, data, client)

      expect(data).to eq({})
    end

    it 'does not store data if the data block does not end with \r\n' do
      command = "set"
      key = "4123456"
      parameters = "10 0 11"
      data = {}
      client = double("client")

      expect(client).to receive(:read).with(13).and_return("Priscila Ruiz").ordered
      expect(client).to receive(:puts).with('Data blocks must end with \r\n'"\r").ordered

      server.set(command, key, parameters, data, client)

      expect(data).to eq({})
    end
  end

  describe 'get' do
    it 'returns the items requested by the client when said items exist' do
      command = "get"
      parameters = "5123456 3123456"
      key = "4123456"
      data = {}
      client = double("client")

      bloque = {}
      bloque["flags"] = "10"
      bloque["exptime"] = "0"
      bloque["bytes"] = "13"
      bloque["body"] = "Priscila Ruiz"
      bloque["cas_unique"] = 1
      data["4123456"] = bloque

      bloque = {}
      bloque["flags"] = "10"
      bloque["exptime"] = "0"
      bloque["bytes"] = "10"
      bloque["body"] = "Juan Perez"
      bloque["cas_unique"] = 1
      data["5123456"] = bloque

      bloque = {}
      bloque["flags"] = "10"
      bloque["exptime"] = "0"
      bloque["bytes"] = "18"
      bloque["body"] = "Agustina Rodriguez"
      bloque["cas_unique"] = 1
      data["3123456"] = bloque

      expect(client).to receive(:puts).with("VALUE 4123456 10 13\r\nPriscila Ruiz\r").ordered
      expect(client).to receive(:puts).with("VALUE 5123456 10 10\r\nJuan Perez\r").ordered
      expect(client).to receive(:puts).with("VALUE 3123456 10 18\r\nAgustina Rodriguez\r").ordered
      expect(client).to receive(:puts).with("END\r").ordered

      server.get(command, key, parameters, data, client)
    end

    it 'only returns the existing items requested by the client' do
      command = "get"
      parameters = "5123456 3123456"
      key = "4123456"
      data = {}
      client = double("client")

      bloque = {}
      bloque["flags"] = "10"
      bloque["exptime"] = "0"
      bloque["bytes"] = "13"
      bloque["body"] = "Priscila Ruiz"
      bloque["cas_unique"] = 1
      data["4123456"] = bloque

      bloque = {}
      bloque["flags"] = "10"
      bloque["exptime"] = "0"
      bloque["bytes"] = "18"
      bloque["body"] = "Agustina Rodriguez"
      bloque["cas_unique"] = 1
      data["3123456"] = bloque

      expect(client).to receive(:puts).with("VALUE 4123456 10 13\r\nPriscila Ruiz\r").ordered
      expect(client).to receive(:puts).with("VALUE 3123456 10 18\r\nAgustina Rodriguez\r").ordered
      expect(client).to receive(:puts).with("END\r").ordered

      server.get(command, key, parameters, data, client)
    end

    it 'does not return anything if no key was given' do
      command = "get"
      key = nil
      parameters = nil
      data = {}
      client = double("client")

      expect(client).to receive(:puts).with("CLIENT_ERROR a key must be given and cannot exceed 250 characters\r")

      server.gets(command, key, parameters, data, client)
    end
  end

  describe 'gets' do
    it 'returns the items requested by the client when said items exist and includes cas unique keys' do
      command = "gets"
      parameters = "5123456 3123456"
      key = "4123456"
      data = {}
      client = double("client")

      bloque = {}
      bloque["flags"] = "10"
      bloque["exptime"] = "0"
      bloque["bytes"] = "13"
      bloque["body"] = "Priscila Ruiz"
      bloque["cas_unique"] = 1
      data["4123456"] = bloque

      bloque = {}
      bloque["flags"] = "10"
      bloque["exptime"] = "0"
      bloque["bytes"] = "10"
      bloque["body"] = "Juan Perez"
      bloque["cas_unique"] = 2
      data["5123456"] = bloque

      bloque = {}
      bloque["flags"] = "10"
      bloque["exptime"] = "0"
      bloque["bytes"] = "18"
      bloque["body"] = "Agustina Rodriguez"
      bloque["cas_unique"] = 3
      data["3123456"] = bloque

      expect(client).to receive(:puts).with("VALUE 4123456 10 13 1\r\nPriscila Ruiz\r").ordered
      expect(client).to receive(:puts).with("VALUE 5123456 10 10 2\r\nJuan Perez\r").ordered
      expect(client).to receive(:puts).with("VALUE 3123456 10 18 3\r\nAgustina Rodriguez\r").ordered
      expect(client).to receive(:puts).with("END\r").ordered

      server.gets(command, key, parameters, data, client)
    end

    it 'only returns the existing items requested by the client and includes cas unique keys' do
      command = "gets"
      parameters = "5123456 3123456"
      key = "4123456"
      data = {}
      client = double("client")

      bloque = {}
      bloque["flags"] = "10"
      bloque["exptime"] = "0"
      bloque["bytes"] = "13"
      bloque["body"] = "Priscila Ruiz"
      bloque["cas_unique"] = 1
      data["4123456"] = bloque

      bloque = {}
      bloque["flags"] = "10"
      bloque["exptime"] = "0"
      bloque["bytes"] = "18"
      bloque["body"] = "Agustina Rodriguez"
      bloque["cas_unique"] = 2
      data["3123456"] = bloque

      expect(client).to receive(:puts).with("VALUE 4123456 10 13 1\r\nPriscila Ruiz\r").ordered
      expect(client).to receive(:puts).with("VALUE 3123456 10 18 2\r\nAgustina Rodriguez\r").ordered
      expect(client).to receive(:puts).with("END\r").ordered

      server.gets(command, key, parameters, data, client)
    end

    it 'does not return anything if no key was given' do
      command = "gets"
      key = nil
      parameters = nil
      data = {}
      client = double("client")

      expect(client).to receive(:puts).with("CLIENT_ERROR a key must be given and cannot exceed 250 characters\r")

      server.gets(command, key, parameters, data, client)
    end
  end
end
