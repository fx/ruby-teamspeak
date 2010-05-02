require 'socket'
include Socket::Constants

module Teamspeak
	TEXTMESSAGETARGET_CLIENT = 1
	TEXTMESSAGETARGET_CHANNEL = 2
	TEXTMESSAGETARGET_SERVER = 3

	class Association < Array
		attr_accessor :parent, :obj_class

		alias_method :array_initialize, :initialize
		def initialize(array, options = {})
			# I'm not making any elaborate tries to be fancy here now, so we just assume the association
			# is given an array of only one type of object, of which we'll take the first to inject finder methods.
			
			# object = array.first
			# object.attributes.each {|k,v|
			# 	self.class.class_eval <<-EOF
			# 	def find_by_#{k.to_s.downcase}
			# 		self.find{|e| e.respond_to?(:attributes) && e.attributes[:#{k}] && e.attributes[:#{k}] == value}
			# 	end
			# 	EOF
			# }

			if options[:parent]
				case options[:parent].class
					when Teamspeak::Server
						array.each{|i| i.server = options[:parent]; i.parent = options[:parent]}
					else
						array.each{|i| i.parent = options[:parent]}
				end
				@parent = options[:parent]
			end

			if options[:class]
				@obj_class = options[:class]
			end
			
			array_initialize(array)
		end

		def method_missing(method, *args)
			if find_attr = method.to_s.scan(/^find_by_(.*)/)
				find_attr = find_attr.to_s.to_sym
				return self.find{|e| e.attributes[find_attr] == args.first.to_s} if self.first.respond_to?(:attributes) && self.first.attributes[find_attr]
			end
		end

		def create(attr = {})
			attr[:parent] ||= parent
			@obj_class.create(attr)
		end
	end

	class Base
		attr_accessor :attributes, :server, :parent, :api
		class << self; attr_accessor :defaults end

		def initialize(attr = {})
			@parent = attr.delete(:parent)

			# We set API functions based on the classname, because they're pretty straight forward mostly
			shortname = self.class.to_s.split('::').last.downcase
			@api = {
				:list => "#{shortname}list",
				:add => "#{shortname}add",
				:delete => "#{shortname}delete"
			}

			@attributes = attr
			@attributes.replace(self.class.defaults.merge(@attributes)) if self.class.defaults # reverse_merge!

			puts self.class.defaults.inspect
			puts @attributes.inspect

			attr.each {|attribute, value|
				value.gsub!('\s', ' ') if value && value.is_a?(String) && !value.empty?
				instance_variable_set("@#{attribute}", value.to_i.to_s == value ? value.to_i : value)

				self.class.class_eval <<-EOF
					def #{attribute}
						instance_variable_get("@#{attribute}")
					end

					def #{attribute}=(v)
						instance_variable_set("@#{attribute}", v)
					end
				EOF
			}
		end

		def update_attributes(attr = {})
			@attributes.replace(@attributes.merge(attr))
		end
		
		def save
			ret = cmd(api[:add], attributes)
			update_attributes(ret) if ret.is_a?(Hash)
		end

		def cmd(command, *args)
			parent.cmd(command, args[0])
		end

		class << self
			def create(attr = {})
				object = new(attr)
				return object if object.save
			end
		end
	end

	class Channel < Teamspeak::Base
		def clients
			@clients ||= Teamspeak::Association.new(server.clients.reject{|client| client.cid != cid}, :class => Teamspeak::Client, :parent => parent)
		end

		def all_clients
			clients | channels.collect(&:all_clients).flatten
		end

		def empty?
			all_clients.empty?
		end

		def channels
			@channels ||= Teamspeak::Association.new(server.channels.reject{|channel| channel.pid != cid}, :class => Teamspeak::Channel, :parent => parent)
		end

		def msg(message = '')
			cmd(:sendtextmessage, :targetmode => TEXTMESSAGETARGET_CHANNEL, :target => cid, :msg => message)
		end

		def cmd(command, *args)
			server.cmd(command, args[0])
		end
	end

	class Group < Teamspeak::Base
	end

	class Token < Teamspeak::Base
		@defaults = {:tokenid2 => 0}
	end

	class Client < Teamspeak::Base
		def cmd(command, *args)
			server.cmd(command, args[0])
		end

		def msg(message = '')
			cmd(:sendtextmessage, :targetmode => TEXTMESSAGETARGET_CLIENT, :target => clid, :msg => message)
		end

		# def method_missing(method, *args)
		# end

		# custom get/set for values that can be changed on the server as well
		def talker=(value)
			client_is_talker = value
		end
		
		def talker
			client_is_talker
		end

		def client_is_talker=(value)
			# return false if ![true, false].include?(value)
			cmd(:clientedit, :clid => clid, :client_is_talker => value ? 1 : 0)
			@client_is_talker = value
		end
		
		def client_is_talker
			@client_is_talker
		end

		class << self
			def find(*args)
			end
		end
	end

	class Server < Teamspeak::Base
		def socket
			Teamspeak.socket
		end
		
		def cmd(command, *args)
			Teamspeak.cmd(:use, id)
			Teamspeak.cmd(command, args[0])
		end
		
		def clients
			@clients ||= cmd(:clientlist)

			# because clientlist should only be called on the Server class, we can assign the server dependency here as well
			@clients.each{|c| c.server = self}

			return @clients
		end

		def groups
			@groups ||= cmd(:servergrouplist)
			@groups.each{|g| g.server = self}
			return Teamspeak::Association.new(@groups, :class => Teamspeak::Group, :parent => self)
		end

		def channels
			@channels ||= cmd(:channellist)
			@channels.each{|g| g.server = self}
			return Teamspeak::Association.new(@channels, :class => Teamspeak::Channel, :parent => self)
		end

		def tokens
			@tokens ||= cmd(:tokenlist)
			return Teamspeak::Association.new(@tokens, :class => Teamspeak::Token, :parent => self)
		end

		# returns a Hash containing all channels and clients in a tree structure
		# def tree
		# 	tree_channels = channels
		# 	tree_clients = clients
		# 	
		# 	@tree = {}
		# 	
		# 	tree_channels.each {|c|
		# 		tree_channels.delete(c)
		# 		@tree["c_#{}"]
		# 	}
		# end

		class << self
			def find(*args)
				puts "Server FIND: #{args.inspect}"

				if args.first.is_a?(Integer)
					Teamspeak.servers.each {|server|
						return server if server.id == args.first
					}
				else
					# find by conditions eh
				end
			end
		end
	end

	def self.config
		config_paths = ['config/teamspeak.yml']
		config_paths << "#{RAILS_ROOT}config/teamspeak.yml" if defined?(RAILS_ROOT)

		if !@config
			config_paths.each {|config_path| 
				if File.exists?(config_path)
					cfg = YAML::load(File.open(config_path)) 
					cfg.each {|key, val|
						@config ||= {}
						@config[key.to_sym] = val
					}
					@config[:port] ||= 10011
					break
				end
			} 
		end
			
		@config ||= false
	end

	def self.config=(cfg = {})
		@config = cfg
	end

	def self.history
		@history ||= []
	end
	
	# def self.history=(command)
	# 	@history << command
	# end

	class << self
		def connected?
			@socket ? true : false
		end

		def connect
			raise Exception if !config

			@socket = TCPSocket.new(config[:host], config[:port])
			ret = @socket.gets # "TS3"
			cmd(:login, :user => config[:user], :password => config[:password])
		end

		def disconnect
			if connected?
				@socket.close
				@socket = nil
			end
		end

		def socket
			connect if !connected?
			@socket
		end

		def gm(msg = '')
			cmd(:gm, :msg => msg)
		end

		def cmd(command, *attributes)
			connect if !connected?

			puts attributes.inspect
			attributes = attributes[0] || []
		
			case command
				when :use
					nvid = attributes.to_i
					if @current_vid && @current_vid == nvid
						puts "use(): current_vid == vid (#{nvid}) - bailing"
						return false
					else
						puts "selecting new vid: #{nvid}"
					end

					_attributes = nvid
				when :login
					_attributes = "#{attributes[:user]} #{attributes[:password]}"
				when :gm
					msg = attributes[:msg].gsub(' ', '\s')
					_attributes = "msg=#{msg}"
				else
					attribute_string = attributes.collect{|a,v| "#{a}=#{v}"}.join(' ')
					_attributes = attributes.any? ? attribute_string : ''
			end

			command_string = !_attributes.to_s.empty? ? "#{command} #{_attributes}" : command

			puts "cmd: #{command_string}"
			socket.puts command_string

			eof = false
			data = ''
			begin
				ret = socket.gets
				if ret
					puts "RAW: #{ret.inspect}"
					rargs = ret.split(' ')
		
					case rargs[0]
					when 'error'
						error = ret.scan(/error id=(\d+) msg=(.*)/)[0]
						error_id = error[0]
						error_msg = error[1]
			
						puts "err: #{error_id} (#{error_msg})"
						eof = true
					
						history << command
					else
						data += ret
					end
				else
 					puts "socket empty: #{socket.inspect}"
				end
			end while !eof

			# TODO make concise intelligent code, you fucktard.
			case command.to_sym
				when :clientlist
					clientlist = data.split('|').map{|client| 
						clientdata = _to_hash(client, 'client_')
						clientdata[:vid] = @current_vid
						Client.new(clientdata)
					}
				when :serverlist
					serverlist = data.split("|").map{|server|
						serverdata = _to_hash(server, 'virtualserver_')
						Server.new(serverdata)
					}
				when :servergrouplist
					grouplist = data.split('|').map{|group|
						groupdata = _to_hash(group)
						Group.new(groupdata)
					}
				when :channellist
					channellist = data.split('|').map{|channel|
						channeldata = _to_hash(channel, 'channel_')
						Channel.new(channeldata)
					}
				when :tokenlist
					tokenlist = data.split('|').map{|token|
						tokendata = _to_hash(token, 'token_')
						Token.new(tokendata)
					}
				when :tokenadd
					token = _to_hash(data.strip.gsub("\\", ''))
					return token
				else
					return data
			end
		end

		def _to_hash(data, strip_key = '')
			data.split(' ').collect{|c| c.split('=')}.inject({}) {|h, el| h[el[0].to_s.gsub(strip_key, '').to_sym] = el[1]; h}
		end

		def servers
			@servers ||= cmd(:serverlist)
			return @servers
		end

	end
end



