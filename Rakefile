require 'rubygems'
require 'rake'
require 'echoe'

Echoe.new('teamspeak', '0.1.0') do |p|
  p.description    = "Teamspeak 3 ServerQuery Library for Ruby"
  p.url            = "http://github.com/fx/ruby-teamspeak"
  p.author         = "Marian Rudzynski"
  p.email          = "mr@impaled.org"
  p.ignore_pattern = ["tmp/*", "script/*"]
  p.development_dependencies = []
end

Dir["#{File.dirname(__FILE__)}/tasks/*.rake"].sort.each { |ext| load ext }

