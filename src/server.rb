require('socket') #get sockets from stdlib
require_relative('service')

class Server

  attr_accessor :service

  def initialize()
    @service = Service.new
  end

  def start_server()
    print "Input the port where you want to run the server: "
    port = gets
    if !(port =~ /^-?[0-9]+$/)
      print "ERROR"
    else
      serverSocket = TCPServer.open('127.0.0.1', port.to_i) #socket to listen on given port
      print "The server is running!"
      loop {
        Thread.start() do
          @service.purge_keys()
        end
        Thread.start(serverSocket.accept) do |client|
          handle_client(client)
        end
      }
    end
  end

  def handle_client(client)
    client.puts "Welcome!\r"
    while line = client.gets
      command,key,parameters = line.split(" ", 3).delete_if(&:empty?)

      case command

      when "set"
        @service.set(command, key, parameters, client)

      when "add"
        @service.add(command, key, parameters, client)

      when "replace"
        @service.replace(command, key, parameters, client)

      when "append"
        @service.append(command, key, parameters, client)

      when "prepend"
        @service.prepend(command, key, parameters, client)

      when "cas"
        @service.cas(command, key, parameters, client)

      when "get"
        @service.get(command, key, parameters, client)

      when "gets"
        @service.gets(command, key, parameters, client)

      when "quit"
        client.close()
        return
      else
        client.puts "ERROR\r"
      end
    end
  end

end
