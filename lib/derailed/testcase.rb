require 'test/unit'
require 'rack/test'

ENV['ENV'] = 'test'

require 'lib/derailed'
require 'lib/controller'

module Derailed
  class TestCase < Test::Unit::TestCase
    include Rack::Test::Methods

    def app
      Rack::Builder.new {
        use Rack::Session::Cookie
        use OpenGovController
        run Derailed::RequestRouter.new
      }
    end

    def login_credentials
      {'user_session' => {
          :username => 'yrral86',
          :password => 'password',
          :password_confirmation => 'password'}}
    end

    def seed_db
      clear_db
      seed_users
    end

    def seed_users
      u = @ch.get_model('Authenticator::user')
      u.create(login_credentials['user_session'])
      u.new({:pam_login => 'larry'}).save(false)
    end

    def clear_db
      @ch.cm.available_models.each do |m|
        next if m == 'Authenticator::usersession'
        model = @ch.get_model(m)
        model.destroy_all
      end
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
      socket_wait('sock', 4)

      @ch = Derailed::ComponentHelper.new
      seed_db
      do_auth if authenticate
    end

    def socket_wait(name, qty)
      waiting = true
      while waiting do
        sockets = Dir.entries(Derailed::Socket.dir).find_all {|e| e.match /#{name}$/}
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
end
