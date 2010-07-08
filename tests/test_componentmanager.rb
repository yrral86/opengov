#!/usr/bin/env ruby1.9.1

require 'test/unit'
require 'rack/test'

require 'requestrouter'
require 'lib/componenthelper'
require 'lib/types/person'

class OpenGovComponentManagerTest < Test::Unit::TestCase
  def app
    OpenGovRequestRouter.new
  end

  def setup
    @browser = Rack::Test::Session.new(Rack::MockSession.new(app))

    `./componentmanager.rb start`
#    sleep 0.05
#    `./components/static.rb start` # required by PersonLocator
#    sleep 0.05 # give the daemons time to start and register themselves
#    `./components/personlocator.rb start`
    sleep 0.05 # give the daemons time to start and register themselves

    @ch = OpenGovComponentHelper.new
  end

  def teardown
    # if an assert fails, make sure we shut down
#    `./components/personlocator.rb stop`

#    `./components/static.rb stop`

    # should kill all components, but not working yet
    `./componentmanager.rb stop`

    # clean up after old request router (in lieu of shutting it down properly)
    `rm /tmp/opengovrequestrouter.sock`
  end
  
  def test_components_register
    assert_equal(
                 ['PersonLocator::address','PersonLocator::person'],
                 @ch.cm.available_models.sort
                 )
  end

  def test_components_unregister
#    `./components/personlocator.rb stop`
    @ch.cm.unregister_component('PersonLocator')
    assert_equal('', @ch.cm.available_models.join(''))
  end

  def test_components_get_model
    person = @ch.get_model("PersonLocator::person")

    larry = person.new(:fname => 'Larry', :lname => 'Reaves')
    larry.save

    assert_equal('Larry', person.find_by_lname('Reaves').fname)

    larry.delete
  end

  def test_abstract_data_type
    person = @ch.get_model("PersonLocator::person")

    larry = person.new(:fname => 'Larry', :lname => 'Reaves')
    larry.save

    larry2 = OpenGovPerson.new(larry)

    assert_equal('Larry', larry2.the_firstest_name)

    larry.delete    
  end
end
