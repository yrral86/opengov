#!/usr/bin/env ruby1.9.1

require 'test/unit'
require 'rack/test'

require 'requestrouter'
require 'lib/controller'

class OpenGovRequestRouterTest < Test::Unit::TestCase
  def app
    Rack::Builder.new {
      use Rack::Session::Cookie
      use OpenGovController
      run OpenGovRequestRouter.new
    }
  end

  def setup
    while Dir.entries('/tmp').detect {|f| f.match /^opengov/ } do
      sleep 0.1
    end

    `./componentmanager.rb start`

    @browser = Rack::Test::Session.new(Rack::MockSession.new(app))

    # give the daemons time to start and register themselves
    waiting = true
    while waiting do
      sockets = Dir.entries('/tmp').find_all {|e| e.match /^opengov/}
      if sockets.length == 3 then
        waiting = false
      else
        sleep 0.1
      end
    end
  end

  def teardown
    # kills all components
    `./componentmanager.rb stop`
  end

  def test_personlist
    @browser.get '/personlocator/person'
    assert @browser.last_response.ok?
  end

  def test_invalid_person_id
    @browser.get '/personlocator/person/bogusid'
    assert_equal 404, @browser.last_response.status
  end
end
