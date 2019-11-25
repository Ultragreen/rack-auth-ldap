lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rack/auth/ldap/version'


Gem::Specification.new do |s|
  s.name = "rack-auth-ldap"
  s.summary = %Q{Rack middleware providing LDAP authentication}
  s.email = "romain@ultragreen.net"
  s.homepage = "http://www.github.com/lecid/rack-auth-ldap"
  s.authors = ["Romain GEORGES"]
  s.version = Rack::Auth::LDAP_VERSION
  s.date = "2014-04-29"
  s.rubyforge_project = 'nowarning'
  s.description = %q{rack-auth-ldap : provide LDAP authentication for Rack middelware}
  s.add_development_dependency('rspec')
  s.add_development_dependency('yard')
  s.add_development_dependency('rdoc')
  s.add_development_dependency('roodi')
  s.add_development_dependency('code_statistics')
  s.add_development_dependency('yard-rspec')
  s.add_development_dependency('ladle')
  s.add_dependency('net-ldap')
  s.add_dependency('rack')
  s.required_ruby_version = '>= 1.9.0'
  s.license       = "BSD"
  s.files         = `git ls-files`.split($/)
end
