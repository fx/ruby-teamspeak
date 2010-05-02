module TeamspeakHelper
	def render_teamspeak_channel(channel, options = {}, depth = 0)

		children = ''
		channel.channels.each {|c|
			children += render_teamspeak_channel(c, options, depth + 1)
		} if channel.channels.any?

		clients = ''
		channel.clients.each {|client|
			clients += render(:partial => options[:partials][:client], :locals => {:client => client}) unless client.nickname.match(/[\d\.]{7}/)
		} if channel.clients.any?

		render(:partial => options[:partials][:channel], :locals => {
			:channel => channel,
			:children => children,
			:clients => clients
		})
	end

	def render_teamspeak_server(options = {})
		options.reverse_merge!({
			:server => Teamspeak.servers.first,
			:partials => {
				:channel => 'teamspeak/channel',
				:client => 'teamspeak/client'
			}
		})

		output = ''
		options[:server].channels.each {|channel|
			output += render_teamspeak_channel(channel, options) if channel.pid == 0
		}

		# Make sure the socket is closed, otherwise mongrel/passenger instances will keep the connection alive
		Teamspeak.disconnect

		return output
	end
end