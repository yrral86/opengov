#!/usr/bin/env ruby1.9.1

require 'test/unit'
require 'rack/test'

require 'requestrouter'

class OpenGovRequestRouterTest < Test::Unit::TestCase
  def app
    OpenGovRequestRouter.new
  end

  def setup
    @browser = Rack::Test::Session.new(Rack::MockSession.new(app))

    `./componentmanager.rb start`
    sleep 1.5 # give the daemons time to start and register themselves
  end

  def teardown
    # kills all components
    `./componentmanager.rb stop`

    `rm /tmp/opengovrequestrouter.sock`

    sleep 1.0 # give everything time to shut down
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
