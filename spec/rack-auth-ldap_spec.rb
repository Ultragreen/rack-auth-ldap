require 'ladle'
require 'rack/auth/ldap'
require 'rack/lint'
require 'rack/mock'

describe Rack::Auth::Ldap do

   before :all do
     @ldap_server = Ladle::Server.new({ 
     :quiet => true, :port   => 3897,
     :ldif   => "./spec/config/users.ldif",
     :domain => "dc=test",
     :tmpdir => '/tmp'                                       
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
      [ 200, {'Content-Type' => 'text/plain'}, ["Hi #{env['REMOTE_USER']}"] ]
    }
  end

  def protected_app
    app = Rack::Auth::Ldap.new(unprotected_app,{:file => "./spec/config/ldap.yml"})
    app.realm = realm
    app
  end

  before do
    @request = Rack::MockRequest.new(protected_app)
  end

  def request_with_basic_auth(username, password, &block)
    request 'HTTP_AUTHORIZATION' => 'Basic ' + ["#{username}:#{password}"].pack("m*"), &block
  end

  def request(headers = {})
    yield @request.get('/', headers)
  end

  def assert_basic_auth_challenge(response)
    response.client_error?.should be true
    response.status.should == 401
    response.should include 'WWW-Authenticate'
    response.headers['WWW-Authenticate'].should =~ /Basic realm="#{Regexp.escape(realm)}"/
    response.body.should be_empty
  end

  it 'should challenge correctly when no credentials are specified' do
    request do |response|
      assert_basic_auth_challenge response
    end
  end

  it 'should rechallenge if incorrect credentials are specified' do
    request_with_basic_auth 'falseuser', 'password' do |response|
      response.client_error?.should be true
      assert_basic_auth_challenge response
    end
  end

  it 'should return application output if correct credentials are specified' do
    request_with_basic_auth 'testuser', 'testpassword' do |response|
      response.client_error?.should be false
      response.status.should == 200
      response.body.to_s.should eq 'Hi testuser'
    end
  end

  it 'should return 400 Bad Request if different auth scheme used' do
    request 'HTTP_AUTHORIZATION' => 'Digest params' do |response|
      response.client_error?.should be true
      response.status.should == 400
      response.should_not include 'WWW-Authenticate'
    end
  end

  it 'should return 400 Bad Request for a malformed authorization header' do
    request 'HTTP_AUTHORIZATION' => '' do |response|
      response.client_error?.should be true
      response.status.should == 400
      response.should_not include 'WWW-Authenticate'
    end
  end
  
  it 'should takes realm as optional constructor arg' do
    app = Rack::Auth::Basic.new(unprotected_app, realm) { true }
    realm.should == app.realm
  end
end
