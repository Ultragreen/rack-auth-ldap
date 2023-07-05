require 'ladle'
require 'rack/auth/ldap'
require 'rack/lint'
require 'rack/mock'

describe Rack::Auth::Ldap do
  before :all do
    @ldap_server = Ladle::Server.new({
                                       quiet: true, port: 3897,
                                       ldif: './spec/config/users.ldif',
                                       domain: 'dc=test',
                                       tmpdir: '/tmp'
                                     }).start
  end

  after :all do
    @ldap_server.stop if @ldap_server
  end

  def realm
    'test'
  end

  def unprotected_app
    Rack::Lint.new lambda { |env|
      [200, { 'content-type' => 'text/plain' }, ["Hi #{env['REMOTE_USER']}"]]
    }
  end

  def protected_app
    app = Rack::Auth::Ldap.new(unprotected_app, { file: './spec/config/ldap.yml' })
    app.realm = realm
    app
  end

  before do
    @request = Rack::MockRequest.new(protected_app)
  end

  def request_with_basic_auth(username, password, &block)
    request 'HTTP_AUTHORIZATION' => 'Basic ' + ["#{username}:#{password}"].pack('m*'), &block
  end

  def request(headers = {})
    yield @request.get('/', headers)
  end

  def assert_basic_auth_challenge(response)
    expect(response.client_error?).to be true
    expect(response.status).to eq 401
    expect(response).to include 'WWW-Authenticate'
    expect(response.headers['WWW-Authenticate']).to match(/Basic realm="#{Regexp.escape(realm)}"/)
    expect(response.body).to be_empty
  end

  it 'should render ldap.yaml with erb and use env vars' do
    allow(ENV).to receive(:[]).with('RACK_ENV')
    allow(ENV).to receive(:[]).with('HOSTNAME').and_return('localhost.local')
    allow(ENV).to receive(:[]).with('PORT').and_return('9090')

    app = Rack::Auth::Ldap.new(unprotected_app, { file: './spec/config/ldap.yml' })
    expect(app.config.hostname).to eq('localhost.local')
    expect(app.config.port).to eq(9090)
  end

  it 'should challenge correctly when no credentials are specified' do
    request do |response|
      assert_basic_auth_challenge response
    end
  end

  it 'should rechallenge if incorrect credentials are specified' do
    request_with_basic_auth 'falseuser', 'password' do |response|
      expect(response.client_error?).to be true
      assert_basic_auth_challenge response
    end
  end

  it 'should return application output if correct credentials are specified' do
    request_with_basic_auth 'testuser', 'testpassword' do |response|
      expect(response.client_error?).to be false
      expect(response.status).to eq 200
      expect(response.body.to_s).to eq 'Hi testuser'
    end
  end

  it 'should return 400 Bad Request if different auth scheme used' do
    request 'HTTP_AUTHORIZATION' => 'Digest params' do |response|
      expect(response.client_error?).to be true
      expect(response.status).to eq 400
      expect(response).not_to include 'WWW-Authenticate'
    end
  end

  it 'should return 400 Bad Request for a malformed authorization header' do
    request 'HTTP_AUTHORIZATION' => '' do |response|
      expect(response.client_error?).to be true
      expect(response.status).to eq 400
      expect(response).not_to include 'WWW-Authenticate'
    end
  end

  it 'should takes realm as optional constructor arg' do
    app = Rack::Auth::Basic.new(unprotected_app, realm) { true }
    expect(realm).to eq app.realm
  end
end
