require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Teamspeak::Server do
	describe "virtual server" do
		it "id 1 should exist" do
			Teamspeak.servers.first.id.should == 1
		end
	end
end