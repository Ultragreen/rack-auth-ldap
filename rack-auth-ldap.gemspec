lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rack/auth/ldap/version'


Gem::Specification.new do |s|
  s.name = "rack-auth-ldap"
  s.summary = %Q{Rack middleware providing LDAP authentication}
  s.email = "romain@ultragreen.net" 
  s.homepage = "http://www.github.com/lecid/rack-auth-ldap"
  s.authors = ["Romain GEORGES"]
  s.version = Rack::Auth::Ldap::VERSION
  s.date = "2014-04-29"
  s.rubyforge_project = 'nowarning'
  s.description = %q{rack-auth-ldap : provide LDAP authentication for Rack middelware}
  s.has_rdoc = true
  s.required_ruby_version = '>= 1.9.0'
  s.license       = "BSD"   
  s.files         = `git ls-files`.split($/)
end



