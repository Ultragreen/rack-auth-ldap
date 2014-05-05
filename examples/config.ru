require 'rubygems'
require 'rack'
gem 'rack-auth-ldap'
require 'rack/auth/ldap'


require File.dirname(__FILE__) + '/sinatra_example'

use Rack::Auth::Ldap
run Sinatra::Application
