#!/usr/bin/env ruby1.9.1

require 'test/unit'
require 'rack/test'

require 'lib/controller'
require 'requestrouter'

class OpenGovAuthenticatorTest < Test::Unit::TestCase
  def app
    OpenGovRequestRouter.new
  end

  def setup
    while Dir.entries('/tmp').detect {|f| f.match /^opengov/ } do
      sleep 0.1
    end

    `./componentmanager.rb start`
    `./components/authenticator.rb start`

    @browser = Rack::Test::Session.new(Rack::MockSession.new(app))

    # give the daemons time to start and register themselves
    waiting = true
    while waiting do
      sockets = Dir.entries('/tmp').find_all {|e| e.match /^opengov/}
      if sockets.length == 4 then
        waiting = false
      else
        sleep 0.1
      end
    end
  end

  def teardown
    # kills all components
    `./components/authenticator.rb stop`
    `./componentmanager.rb stop`
  end

  def test_getlogin
    assert false, "no middleware"
    # this won't work until we figure out how to enable middlewear in tests
    # @browser.get '/login'
    # assert @browser.last_response.ok?
  end

  def test_getnewuser
    assert false, "no middleware"
    # same as above
    # @browser.get '/newuser'
    # assert @browser.last_response.ok?    
  end
end
