#!/usr/bin/env ruby1.9.1

require 'test/unit'
require 'rack/test'

require 'requestrouter'
require 'lib/componenthelper'

class OpenGovRequestRouterTest < Test::Unit::TestCase
  def app
    OpenGovRequestRouter.new
  end

  def setup
    @browser = Rack::Test::Session.new(Rack::MockSession.new(app))

    `./componentmanager.rb start`
    sleep 0.05
    `./components/static.rb start` # required by PersonLocator
    sleep 0.05 # give the daemons time to start and register themselves
    `./components/personlocator.rb start`
    sleep 0.05 # give the daemons time to start and register themselves

    @ch = OpenGovComponentHelper.new
  end

  def teardown
    # if an assert fails, make sure we shut down
    `./components/personlocator.rb stop`

    `./components/static.rb stop`

    # should kill all components, but not working yet
    `./componentmanager.rb stop`

    `rm /tmp/opengovrequestrouter.sock`
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
