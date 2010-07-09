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
    sleep 1.5 # give the daemons time to start and register themselves

    @ch = OpenGovComponentHelper.new
  end

  def teardown
    # kills all components
    `./componentmanager.rb stop`

    `rm /tmp/opengovrequestrouter.sock`

    sleep 1.5
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
