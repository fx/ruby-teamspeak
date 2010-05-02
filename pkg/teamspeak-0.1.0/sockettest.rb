require 'socket'

s = TCPSocket.new('google.com', 80)
s.puts "GET / HTTP/1.1"
s.puts "\n"
puts s.gets(nil)

