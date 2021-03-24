# Memcached Server
This is a Memcached TCP server that complies with the specified protocol.

This server supports a subset of 8 Memcached commands.

Storage commands:
* set
* add
* replace
* append
* prepend
* cas

Retrieval commands:
* get
* gets

## How to run the server
Use the following command on the 'Memcached server' folder:
```
$ ruby start_server.rb
```

## How to run a demo client
Use telnet to connect to the server.
```
$ telnet localhost 2000
```

### Sample commands
Once you are connected to the server you can type in commands as follows:
1. set
```
set <key> <flags> <exptime> <bytes>
<data block>
```
```
set 4123456 10 0 13
Priscila Ruiz
```
2. add
```
add <key> <flags> <exptime> <bytes>
<data block>
```
```
add 5123456 10 0 10
Juan Perez
```
3. replace
```
replace <key> <flags> <exptime> <bytes>
<data block>
```
```
set 4123456 10 0 13
Priscila Ruiz
replace 4123456 9 0 10
Juan Perez
```
4. append
```
append <key> <bytes>
<data block>
```
```
set 4123456 10 0 13
Priscila Ruiz
append 4123456 10
Coccinello
```
5. prepend
```
prepend <key> <bytes>
<data block>
```
```
set 5123456 10 0 12
Manuel Perez
prepend 5123456 4
Juan
```
6. cas
```
cas <key> <flags> <exptime> <bytes> <cas_unique>
<data block>
```
```
set 3123456 10 0 13
Priscila Ruiz
cas 3123456 10 0 24 1
Priscila Ruiz Coccinello
```
7. get
```
get <key>
```
or
```
get <key1> <key2> .. <keyN>
```
```
set 4123456 10 0 13
Priscila Ruiz
set 5123456 10 0 10
Juan Perez
get 5123456
get 5123456 4123456
```
8. gets
```
gets <key>
```
or
```
gets <key1> <key2> .. <keyN>
```
```
set 4123456 10 0 13
Priscila Ruiz
set 5123456 10 0 10
Juan Perez
gets 5123456
gets 5123456 4123456
```

## How to run the tests

### Unit tests
Use the following command on the 'Memcached server' folder:
```
$ rspec server_spec.rb
```

### Load tests
To run the load tests you _must_ have the server running.

Open the 'Test Plan.jmx' file using the JMeter application and run it.

Results will be shown on the summary report.
