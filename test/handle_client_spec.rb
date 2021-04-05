require_relative '../src/server'

RSpec.configure do |config|
  config.formatter = :documentation
end

describe Server do
  server = Server.new

  describe 'handle_client' do
    it 'calls method set if the passed command is set' do
      command = "set"
      key = "4123456"
      parameters = "10 0 13"
      data = {}
      client = double("client")

      #these 'expect' are necessary because of the server's design
      expect(client).to receive(:puts).with("Welcome!\r").ordered
      expect(client).to receive(:gets).and_return("set 4123456 10 0 13").ordered

      #this is the behavior beeing tested
      expect(server.service()).to receive(:set).with(command, key, parameters, client).ordered

      #this 'expect' is necessary because of the server's design
      expect(client).to receive(:gets).and_return(NIL).ordered

      server.handle_client(client)
    end

    it 'calls method add if the passed command is add' do
      command = "add"
      key = "4123456"
      parameters = "10 0 13"
      data = {}
      client = double("client")

      #these 'expect' are necessary because of the server's design
      expect(client).to receive(:puts).with("Welcome!\r").ordered
      expect(client).to receive(:gets).and_return("add 4123456 10 0 13").ordered

      #this is the behavior beeing tested
      expect(server.service()).to receive(:add).with(command, key, parameters, client).ordered

      #this 'expect' is necessary because of the server's design
      expect(client).to receive(:gets).and_return(NIL).ordered

      server.handle_client(client)
    end

    it 'calls method replace if the passed command is replace' do
      command = "replace"
      key = "4123456"
      parameters = "10 0 13"
      data = {}
      client = double("client")

      #these 'expect' are necessary because of the server's design
      expect(client).to receive(:puts).with("Welcome!\r").ordered
      expect(client).to receive(:gets).and_return("replace 4123456 10 0 13").ordered

      #this is the behavior beeing tested
      expect(server.service()).to receive(:replace).with(command, key, parameters, client).ordered

      #this 'expect' is necessary because of the server's design
      expect(client).to receive(:gets).and_return(NIL).ordered

      server.handle_client(client)
    end

    it 'calls method append if the passed command is append' do
      command = "append"
      key = "4123456"
      parameters = nil
      data = {}
      client = double("client")

      #these 'expect' are necessary because of the server's design
      expect(client).to receive(:puts).with("Welcome!\r").ordered
      expect(client).to receive(:gets).and_return("append 4123456").ordered

      #this is the behavior beeing tested
      expect(server.service()).to receive(:append).with(command, key, parameters, client).ordered

      #this 'expect' is necessary because of the server's design
      expect(client).to receive(:gets).and_return(NIL).ordered

      server.handle_client(client)
    end

    it 'calls method prepend if the passed command is prepend' do
      command = "prepend"
      key = "4123456"
      parameters = nil
      data = {}
      client = double("client")

      #these 'expect' are necessary because of the server's design
      expect(client).to receive(:puts).with("Welcome!\r").ordered
      expect(client).to receive(:gets).and_return("prepend 4123456").ordered

      #this is the behavior beeing tested
      expect(server.service()).to receive(:prepend).with(command, key, parameters, client).ordered

      #this 'expect' is necessary because of the server's design
      expect(client).to receive(:gets).and_return(NIL).ordered

      server.handle_client(client)
    end

    it 'calls method cas if the passed command is cas' do
      command = "cas"
      key = "4123456"
      parameters = "10 0 13 1"
      data = {}
      client = double("client")

      #these 'expect' are necessary because of the server's design
      expect(client).to receive(:puts).with("Welcome!\r").ordered
      expect(client).to receive(:gets).and_return("cas 4123456 10 0 13 1").ordered

      #this is the behavior beeing tested
      expect(server.service()).to receive(:cas).with(command, key, parameters, client).ordered

      #this 'expect' is necessary because of the server's design
      expect(client).to receive(:gets).and_return(NIL).ordered

      server.handle_client(client)
    end

    it 'calls method get if the passed command is get' do
      command = "get"
      key = "4123456"
      parameters = nil
      data = {}
      client = double("client")

      #these 'expect' are necessary because of the server's design
      expect(client).to receive(:puts).with("Welcome!\r").ordered
      expect(client).to receive(:gets).and_return("get 4123456").ordered

      #this is the behavior beeing tested
      expect(server.service()).to receive(:get).with(command, key, parameters, client).ordered

      #this 'expect' is necessary because of the server's design
      expect(client).to receive(:gets).and_return(NIL).ordered

      server.handle_client(client)
    end

    it 'calls method gets if the passed command is gets' do
      command = "gets"
      key = "4123456"
      parameters = nil
      data = {}
      client = double("client")

      #these 'expect' are necessary because of the server's design
      expect(client).to receive(:puts).with("Welcome!\r").ordered
      expect(client).to receive(:gets).and_return("gets 4123456").ordered

      #this is the behavior beeing tested
      expect(server.service()).to receive(:gets).with(command, key, parameters, client).ordered

      #this 'expect' is necessary because of the server's design
      expect(client).to receive(:gets).and_return(NIL).ordered

      server.handle_client(client)
    end

    it 'returns error message if the passed command does not exist' do
      command = "random"
      key = nil
      parameters = nil
      data = {}
      client = double("client")

      #these 'expect' are necessary because of the server's design
      expect(client).to receive(:puts).with("Welcome!\r").ordered
      expect(client).to receive(:gets).and_return("random").ordered

      #this is the behavior beeing tested
      expect(client).to receive(:puts).with("ERROR\r").ordered
      
      #this 'expect' is necessary because of the server's design
      expect(client).to receive(:gets).and_return(NIL).ordered

      server.handle_client(client)
    end
  end
end
