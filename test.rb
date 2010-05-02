require 'lib/teamspeak'

Teamspeak.config = {
	:host => 'ts.aesyr.com',
	:user => 'serveradmin',
	:password => 'YyQR7bdo'		
}

# Teamspeak.gm('Fantastoidisch! Beta 9..')
# exit

# puts Teamspeak.servers.inspect
# 
ts = Teamspeak::Server.find(1)

# DEBUG - 'disable' antiflood measures 
# ts.cmd(:instanceedit, :serverinstance_serverquery_flood_commands => 999, :serverinstance_serverquery_flood_time => 1)

puts ts.inspect
puts ts.id

def _render_channel(channel, depth = 0)
	output = ''
	prefix = ("\t" * depth)

	output += prefix + "Channel: #{channel.name} (all_clients: #{channel.all_clients.size} -- #{channel.all_clients.map{|c|c.class.to_s+','}})\n"

	channel.channels.each {|c|
		output += _render_channel(c, depth + 1)
	}
	channel.clients.each {|client|
		output += prefix + "   |-@ #{client.nickname}\n"
	}
	return output
end

def render_tree(server)
	output = ''
	server.channels.each {|channel|
		output += _render_channel(channel) if channel.pid == 0
	}
	return output
end



puts render_tree(Teamspeak.servers.first)



aesyr = ts.groups.find_by_name('Aesyr')
puts aesyr.attributes.inspect

# puts ts.tokens.inspect

# t = Teamspeak::Token.new(:tokentype => 0, :tokenid1 => aesyr.sgid, :tokendescription => 'testing')
# t.parent = ts
# t.save

# t = ts.tokens.create(:tokentype => 0, :tokenid1 => aesyr.sgid, :tokendescription => 'testing')
# 
# puts t.attributes.inspect

# # puts ts.clients.inspect
# 
# puts "-----------------\n\n"
# ts.clients.each {|c|
# 	puts "\tClient: #{c.nickname}\n"
# 	puts c.inspect
# 	puts "\n"
# 
# 	if c.nickname == 'fyrn'
# 		# c.message('FUCK YOU OIDA')
# 		c.client_is_talker = false
# 	end
# }
# puts "-----------------\n\n"

# puts "-----------------\n\n"
# ts.groups.each {|g|
# 	puts "\tGroup: #{g.name}\n"
# 	puts g.inspect
# 	puts "\n"
# 
# 	if g.name == 'Server\sAdmin'
# 		g.message('group message test')
# 	end
# }
# puts "-----------------\n\n"

# puts "-----------------\n\n"
# ts.channels.each {|c|
# 	puts "\tChannel: #{c.name}\n"
# 	puts c.inspect
# 	puts "\n"
# 	
# 	if c.name == 'AFK'
# 		c.msg('lolz!')
# 	end
# }
# puts "-----------------\n\n"
