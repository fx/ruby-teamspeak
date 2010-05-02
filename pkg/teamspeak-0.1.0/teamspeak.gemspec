# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{teamspeak}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Marian Rudzynski"]
  s.date = %q{2009-12-27}
  s.description = %q{Teamspeak 3 ServerQuery Library for Ruby}
  s.email = %q{mr@impaled.org}
  s.extra_rdoc_files = ["lib/teamspeak.rb", "tasks/spec.rake"]
  s.files = ["Manifest", "Rakefile", "lib/teamspeak.rb", "sockettest.rb", "spec/spec_helper.rb", "spec/teamspeak/base_spec.rb", "spec/teamspeak/server_spec.rb", "tasks/spec.rake", "test.rb", "teamspeak.gemspec"]
  s.homepage = %q{http://github.com/fx/ruby-teamspeak}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Teamspeak"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{teamspeak}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Teamspeak 3 ServerQuery Library for Ruby}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
