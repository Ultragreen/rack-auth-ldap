# inhibit warning : due to net-ldap warning on Socket.tcp
$-w = nil

require 'rack'
require 'net/ldap'
require 'rack/auth/abstract/handler'
require 'rack/auth/abstract/request'
require 'yaml'

# the rack module from Rack Sources
module Rack
  # the auth module from Rack Sources
  module Auth
    # class Config provide Yaml config mapping for Rack::Auth::Module
    # the class map ldap configurations values
    # @note this class is not provide to be used standalone
    class Config
      # initializer for Config class
      # @param [Hash<Symbol>] options initialisation options
      # @option options [Symbol] :file The YAML filename (default to ./ldap.yml, the config.ru path)
      # @return [Config] object himself
      def initialize(options = { file: './ldap.yml' })
        @values = defaults
        options.merge!(file: './ldap.yml') { |_key, oldval, _newval| oldval }
        target = ENV['RACK_ENV'] || 'test'
        config_values = load_yaml(::File.expand_path(options[:file], Dir.pwd))[target]
        debug = ::File.open('/tmp/test.txt', 'a+')
        debug.puts ENV.fetch('RACK_ENV', nil)
        debug.close
        config_values.keys.each do |key|
          config_values[key.to_sym] = config_values.delete(key)
        end
        @values.merge! config_values
        @values.keys.each do |meth|
          bloc = proc { @values[meth] }
          self.class.send :define_method, meth, &bloc
        end
      end

      private

      def load_yaml(file)
        raise "Could not load ldap configuration. No such file - #{file}" unless ::File.exist?(file)

        ::YAML.load ::ERB.new(IO.read(file)).result
      rescue ::Psych::SyntaxError => e
        raise "YAML syntax error occurred while parsing #{file}. " \
              'Please note that YAML must be consistently indented using spaces. Tabs are not allowed. ' \
              "Error: #{e.message}"
      end

      # private method with default configuration values for LDAP
      # @return [Hash<Symbol>] the default values of LDAP configuration
      def defaults
        {
          hostname: 'localhost',
          basedn: 'dc=domain,dc=tld',
          rootdn: '',
          passdn: '',
          auth: false,
          port: 389,
          scope: :subtree,
          username_ldap_attribute: 'uid',
          ldaps: false,
          starttls: false,
          tls_options: nil,
          debug: false
        }
      end
    end

    # class Ldap, the main authentication component for Rack
    # inherited from the default Rack::Auth::AbstractHandler
    # @note please do not instantiate, this classe is reserved to Rack
    # @example Usage
    #   # in a config.ru
    #   gem 'rack-auth-ldap'
    #   require 'rack/auth/ldap'
    #   use Rack::Auth::Ldap
    class Ldap < AbstractHandler
      # the config read accessor
      # @attr [Rack::Auth::Config] the read accessor to the LDAP Config object
      attr_reader :config

      # initializer for the Ldap Class
      # @note please don not instantiate without rack config.ru
      # @see Rack::Auth::Ldap
      # @return [Ldap] self object
      # @param [Block,Proc,Lambda] app the rack application
      # @param [hash<Symbol>] config_options the configurable options
      # @option config_options [Symbol] :file the path to the YAML configuration file
      def initialize(app, config_options = {})
        super(app)
        @config = Config.new(config_options)
      end

      # call wrapper to provide authentication if not
      # @param [Hash] env the rack environnment variable
      # @return [Array] the tri-dimensional Array [status,headers,[body]]
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

      # forge a challange header for HTTP basic auth with the realm attribut
      # @return [String] the header
      def challenge
        'Basic realm="%s"' % realm
      end

      # do the LDAP connection => search => bind with the credentials get into request headers
      # @param [Rack::Auth::Ldap::Request] auth a LDAP authenticator object
      # @return [TrueClass,FalseClass] Boolean true/false
      def valid?(auth)
        # how to connect to the ldap server: ldap, ldaps, ldap + starttls
        if @config.ldaps
          enc = { method: :simple_tls }
        elsif @config.starttls
          enc = { method: :start_tls }
          enc[:tls_options] = @config.tls_options if @config.tls_options
        else
          enc = nil # just straight ldap
        end
        conn = Net::LDAP.new(host: @config.hostname, port: @config.port,
                             base: @config.basedn,
                             encryption: enc)

        $stdout.puts "Net::LDAP.new => #{conn.inspect}" if @config.debug

        if @config.auth
          $stdout.puts "doing auth for #{@config.rootdn.inspect}" if @config.debug
          conn.auth @config.rootdn, @config.passdn
          # conn.get_operation_result.message has the reson for a failure
          return false unless conn.bind
        end

        filter = Net::LDAP::Filter.eq(@config.username_ldap_attribute,
                                      auth.username)

        $stdout.puts "Net::LDAP::Filter.eq => #{filter.inspect}" if @config.debug

        # find the user and rebind as them to test the password
        # return conn.bind_as(:filter => filter, :password => auth.password)
        $stdout.puts "doing bind_as password.size: #{auth.password.size}..." if @config.debug
        ret = conn.bind_as(filter: filter, password: auth.password)
        $stdout.puts "bind_as => #{ret.inspect}" if @config.debug
        ret
      end

      # Request class the LDAP credentials authenticator
      # @note please do not instantiate manually, used by Rack::Auth:Ldap
      class Request < Auth::AbstractRequest
        # return true if the auth scheme provide is really a basic scheme
        # @return [FalseClass,TrueClass] the result
        def basic?
          !parts.first.nil? && 'basic' == scheme
        end

        # return an array of the two credentials [username,password]
        # @return [Array] the couple [username,password]
        def credentials
          @credentials ||= params.unpack1('m*').split(':', 2)
        end

        # read accessor on the first credentials, username
        # @return [String] the username
        def username
          credentials.first
        end

        # read accessor on the last credentials, password
        # @return [String] the password
        def password
          credentials.last
        end
      end
    end
  end
end
