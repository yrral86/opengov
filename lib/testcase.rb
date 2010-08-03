require 'test/unit'
require 'rack/test'

require 'requestrouter'
require 'lib/controller'

class OpenGovTestCase < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Rack::Builder.new {
      use Rack::Session::Cookie
      use OpenGovController
      run OpenGovRequestRouter.new
    }
  end

  def login_credentials
    {'user_session' => {
        :username => 'yrral86', :password => 'password'}}
  end

  def do_auth(credentials=login_credentials)
    post '/login', credentials
    follow_redirects
    assert last_response.ok?, "Login failed with credentials #{credentials}"
  end

  def follow_redirects
    while last_response.status == 302
      follow_redirect!
    end
  end

  def setup(authenticate=true)
    # make sure the sockets are ready
    socket_wait('opengov', 4)
    if authenticate
      do_auth
    end
  end

  def socket_wait(name, qty)
    waiting = true
    while waiting do
      sockets = Dir.entries('/tmp').find_all {|e| e.match /^#{name}/}
      if sockets.length == qty then
        waiting = false
      else
        sleep 0.05
      end
    end
  end

  def teardown
    true
  end
end
