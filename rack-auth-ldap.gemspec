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


  s.description = %q{rack-auth-ldap : provide LDAP authentication for Rack middelware}
  s.add_development_dependency 'rspec', '~> 3.9.0'
  s.add_development_dependency 'yard', '~> 0.9.24'
  s.add_development_dependency 'rdoc', '~> 6.2.1'
  s.add_development_dependency 'roodi', '~> 5.0.0'
  s.add_development_dependency 'code_statistics', '~> 0.2.13'
  s.add_development_dependency 'yard-rspec', '~> 0.1'
  s.add_development_dependency 'ladle', '~> 1.0.1'
  s.add_development_dependency 'rake', '~> 13.0.1'




  s.add_dependency 'net-ldap', '~> 0.16.2'
  s.add_dependency 'rack', '~> 2.2.2'
  s.license       = "BSD-2-Clause"
  s.files         = `git ls-files`.split($/)
end
