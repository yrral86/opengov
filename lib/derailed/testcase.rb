require 'test/unit'
require 'rack/test'

ENV['ENV'] = 'test'

require 'derailed'

module Derailed
  # = Derailed::TestCase
  # This class provides everything needed to test the application.
  # It assembles the app by reading config.ru, ensures the components are
  # started, seeds the database and authenticates a user (unless you disable
  # authentication, as in test_authenticator.rb)
  class TestCase < Test::Unit::TestCase
    include Test::Unit::Assertions
    include Rack::Test::Methods

    # app returns the app built from the config file by Rack::Builder
    def app
      Rack::Builder.parse_file('config.ru')[0]
    end

    # login_credentials returns a hash with login credentials
    def login_credentials
      {'user_session' => {
          :username => 'test_user',
          :password => 'test_password',
          :password_confirmation => 'test_password'}}
    end

    # seed_db clears the db and seeds the users
    def seed_db
      clear_db
      seed_users
    end

    # seed_users creates two users, a db user defined by login_credentials
    # and a pam user with login `whoami`
    def seed_users
      u = Service.get('Authenticator').model('User')
      u.create(login_credentials['user_session'])
      u.new({:pam_login => `whoami`.chomp}).save(false)
    end

    # clear_db calls clear_models on all available components
    def clear_db
      @manager.available_components.each do |c|
        Service.get(c).clear_models
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

    # setup waits for the components to start, creates a Client,
    # calls seed_db, and authenticates the user unless false is passed in
    def setup(authenticate=true)
      # make sure the sockets are ready
      TestCase.socket_wait

      @manager = Service.get 'Manager'
      seed_db
      do_auth if authenticate
    end

    # self.socket_wait waits until all the component sockets are ready
    # this should probably be better defined somewhere else... also called
    # from Rakefile during setup_test task
    def self.socket_wait
      old_dir = Dir.pwd
      Dir.chdir Config::ComponentDir
      qty = Dir.glob('*').length + 1
      Dir.chdir old_dir

      waiting = true
      while waiting do
        sockets = Dir.entries(Socket.dir).find_all {|e|
          e.match /sock$/
        }
        if sockets.length == qty
          waiting = false
        else
          sleep 0.05
        end
      end
    end
  end
end
