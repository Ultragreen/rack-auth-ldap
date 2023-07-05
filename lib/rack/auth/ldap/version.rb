# Author : Romain GEORGES
require 'version'
# the Rack module from Rack Sources
module Rack
  # the Rack::Auth module from Rack Sources
  module Auth
    # the current version for Rack::Auth::Ldap => gem rack-auth-ldap
    # used by gemspec
    LDAP_VERSION = Version.current
  end
end
