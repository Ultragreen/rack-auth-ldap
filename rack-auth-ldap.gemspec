lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rack/auth/ldap/version'

Gem::Specification.new do |s|
  s.name = 'rack-auth-ldap'
  s.summary = %(Rack middleware providing LDAP authentication)
  s.email = 'romain@ultragreen.net'
  s.homepage = 'http://www.github.com/lecid/rack-auth-ldap'
  s.authors = ['Romain GEORGES']
  s.version = Rack::Auth::LDAP_VERSION

  s.description = 'rack-auth-ldap : provide LDAP authentication for Rack middelware'
  s.add_development_dependency 'bundle-audit', '~> 0.1.0'
  s.add_development_dependency 'code_statistics', '~> 0.2.13'
  s.add_development_dependency 'ladle', '~> 1.0.1'
  s.add_development_dependency 'rake', '~> 13.0.1'
  s.add_development_dependency 'rspec', '~> 3.12.0'
  s.add_development_dependency 'rubocop', '~> 1.54'
  s.add_development_dependency 'version', '~> 1.1'
  s.add_development_dependency 'yard', '~> 0.9.24'
  s.add_development_dependency 'yard-rspec', '~> 0.1'

  s.add_development_dependency 'cyclonedx-ruby', '~> 1.1'
  s.add_development_dependency 'debride', '~> 1.12'

  s.add_dependency 'net-ldap', '~> 0.18'
  s.add_dependency 'rack', '~> 3.0'
  s.license       = 'BSD-2-Clause'
  s.files         = `git ls-files`.split($/)
  s.metadata['rubygems_mfa_required'] = 'true'
end
