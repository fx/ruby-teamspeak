Installation
---

script/plugin install http://github.com/fx/ruby-teamspeak.git


Usage
---

config/ and RAILS_ROOT/config/ (for those using it in a Rails project) will be
checked for a 'teamspeak.yml' file, that looks like this:

host: ts.aesyr.com
port: 10011
user: serveradmin
password: hFS7FhsdCS5

Use your own data, obviously.


If you simply want to render a tree of your server in a view, insert this:

<% cache 'teamspeak', :expires_in => 1.minutes do -%>
	<%= render :partial => 'teamspeak/server' %>
<% end -%>

This uses expires_in (which requires Memcache, for example) on the cache
method - because, really, you do want to cache this somehow.

Default views for this are included and you can simply override them by having
them present in your own app/views/ directory.

You might want to style the output too - you'll figure it out.
