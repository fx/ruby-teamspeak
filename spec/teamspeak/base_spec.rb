require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Teamspeak do

	# The connection tests should progress linearly and as first tests
	describe 'connection' do
		it 'should persist' do
			# Teamspeak should not connect until required
			Teamspeak.connected?.should == false
			
			# Every command execution should connect
			Teamspeak.servers.should_not be_empty

			# And after command execution, the socket should obviously be kept open
			Teamspeak.connected?.should == true
		end

		# Teamspeak#cmd will keep a history of commands executed
		# through the course of multiple commands, this should not include multiple :login calls
		it 'should only log in once' do
			# Since we've progressed through the above tests, history should probably be [:login, :serverlist]
			Teamspeak.history.should include(:login)
			
			# Now we simply directly call cmd(), which checks connected? and calls connect() if false
			# connect() will also log in - which it shouldn't unless the connection is dropped, obviously
			Teamspeak.cmd(:serverlist)
			
			Teamspeak.history.count(:login).should == 1
		end
	end
end