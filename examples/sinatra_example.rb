require 'rubygems'
require 'sinatra'

require 'haml'



get '/' do
 haml :index
end


enable :inline_templates

__END__

@@ index 
%h1 Rack::Auth::Ldap test 
%p= "Hello #{request.env['REMOTE_USER']} !"
 

