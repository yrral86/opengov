require 'rubygems'
require 'test/unit'
require 'rack/test'

ENV['ENV'] = 'test'

dir = File.expand_path(File.dirname(__FILE__))
require dir + '/../derailed'

module Derailed
  # = Derailed::TestCase
  # This class provides everything needed to test the application.
  # It assembles the app by reading config.ru, ensures the components are
  # started, seeds the database and authenticates a user (unless you disable
  # authentication, as in test_authenticator.rb)
#  class TestCase < Test::Unit::TestCase
  module TestCase
    include Test::Unit::Assertions
    include Rack::Test::Methods

    # app returns the app built from the config file by Rack::Builder
    def app
      Rack::Builder.parse_file('config.ru')[0]
    end

    # login_credentials returns a hash with login credentials
    def login_credentials
      {'user_session' => {
          :username => 'yrral86',
          :password => 'password',
          :password_confirmation => 'password'}}
    end

    # seed_db clears the db and seeds the users
    def seed_db
      clear_db
      seed_users
    end

    # seed_users creates two users, a db user defined by login_credentials
    # and a pam user with login 'larry'
    def seed_users
      u = @cc.get_model('Authenticator::User')
      u.create(login_credentials['user_session'])
      u.new({:pam_login => 'larry'}).save(false)
    end

    # clear_db calls destroy_all on all available models except
    # Authenticator::usersession, which has no db backing
    def clear_db
      @cc.cm.available_models.each do |m|
        next if m == 'Authenticator::UserSession'
        model = @cc.get_model(m)
        model.destroy_all
      end
    end

    # do_auth authenticates the user
    def do_auth(credentials=login_credentials)
      post '/login', credentials
      follow_redirects
      assert last_response.ok?, "Login failed with credentials #{credentials}"
    end

    # follow_redirects redirects until we have a response that isn't a redirect
    def follow_redirects
      while last_response.status == 302
        follow_redirect!
      end
    end

    # setup waits for the components to start, creates a ComponentClient,
    # calls seed_db, and authenticates the user unless false is passed in
    def setup(authenticate=true)
      # make sure the sockets are ready
      socket_wait('sock', 4)

      @cc = ComponentClient.new
      seed_db
      do_auth if authenticate
    end

    # socket_wait waits until all the component sockets are ready
    def socket_wait(name, qty)
      waiting = true
      while waiting do
        sockets = Dir.entries(Manager::Socket.dir).find_all {|e|
          e.match /#{name}$/
        }
        if sockets.length == qty then
          waiting = false
        else
          sleep 0.05
        end
      end
    end

    class Unit < Test::Unit::TestCase
      include Derailed::TestCase
    end
  end
end
