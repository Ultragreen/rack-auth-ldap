require 'rack'
require 'ldap'
require 'rack/auth/abstract/handler'
require 'rack/auth/abstract/request'

module Rack
  module Auth

    class Config
      def initialize(options = {})
        @values = defaults
        config_options = YAML.load_file(::File.expand_path('ldap.yml', Dir.pwd))[ENV['RACK_ENV']]          
        config_options.keys.each do |key|
          config_options[key.to_sym] = config_options.delete(key)
        end
        @values.merge! options
        @values.merge! config_options
        @values.keys.each do |meth|
          bloc = Proc.new  {@values[meth] } 
            self.class.send :define_method, meth, &bloc  
        end                                
      end
      
      private 
      def defaults
        return {
          :hostname => 'localhost',
          :basedn => 'dc=domain,dc=tld',
          :rootdn => '',
          :passdn => '',
          :auth => false,
          :port => 389,
          :scope => :subtree,
          :username_ldap_attribute => 'uid',
        }
      end


    end


    class Ldap < AbstractHandler

      attr_reader :config

      def initialize(app, config_options = {})
        super(app)
        @config = Config.new(config_options)
      end


      def call(env)
        auth = Ldap::Request.new(env)
        return unauthorized unless auth.provided?
        return bad_request unless auth.basic?
        if valid?(auth)
          env['REMOTE_USER'] = auth.username
          return @app.call(env)
        end
        unauthorized
      end


      private

      def challenge
        'Basic realm="%s"' % realm
      end

      def valid?(auth)        
        dn = ''
        conn = LDAP::Conn.new(@config.hostname, @config.port)
        conn.set_option( LDAP::LDAP_OPT_PROTOCOL_VERSION, 3 )
        conn.simple_bind(@config.rootdn,@config.passdn) if @config.auth 
        filter = "(#{@config.username_ldap_attribute}=#{auth.username})"
        conn.search(@config.basedn, ldap_scope(@config.scope), filter) do |entry|
          dn = entry.dn
        end
        return false if dn.empty?
        conn.unbind
        conn = LDAP::Conn.new(@config.hostname, @config.port)
        conn.set_option( LDAP::LDAP_OPT_PROTOCOL_VERSION, 3 )
        begin
          return conn.simple_bind(dn, auth.password)
        rescue LDAP::ResultError
          return false
        end
      end

      private
      def ldap_scope(_scope)
        res = {
          :subtree => ::LDAP::LDAP_SCOPE_SUBTREE,
          :one => ::LDAP::LDAP_SCOPE_ONELEVEL
        }
        return res[_scope]
      end




      class Request < Auth::AbstractRequest
        def basic?
          !parts.first.nil? && "basic" == scheme
        end

        def credentials
          @credentials ||= params.unpack("m*").first.split(/:/, 2)
        end

        def username
          credentials.first
        end

        def password
          credentials.last
        end

      end

    end
  end
end



