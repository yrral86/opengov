#!/usr/bin/env ruby1.9.1

require 'test/unit'
require 'lib/componenthelper'
require 'rack/test'
require 'requestrouter'

class OpenGovRequestRouterTest < Test::Unit::TestCase
#  include Rack::Test::Methods

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
  end

  def test_personlist
    @browser.get '/personlocator/person'
    assert @browser.last_response.ok?
  end
end
