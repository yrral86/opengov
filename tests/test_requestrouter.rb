#!/usr/bin/env ruby1.9.1

require 'test/unit'
require 'rack/test'

require 'requestrouter'

class OpenGovRequestRouterTest < Test::Unit::TestCase
  def app
    OpenGovRequestRouter.new
  end

  def setup
    `./componentmanager.rb start`

    @browser = Rack::Test::Session.new(Rack::MockSession.new(app))

    sleep 1.5 # give the daemons time to start and register themselves
  end

  def teardown
    # kills all components
    `./componentmanager.rb stop`
    sleep 1.5
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
