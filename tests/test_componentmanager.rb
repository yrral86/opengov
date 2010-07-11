#!/usr/bin/env ruby1.9.1

require 'test/unit'
require 'rack/test'

require 'lib/componenthelper'
require 'lib/types/person'

class OpenGovComponentManagerTest < Test::Unit::TestCase
  def setup
    while Dir.entries('/tmp').detect {|f| f.match /^opengov/ } do
      sleep 0.1
    end

    `./componentmanager.rb start`

    @ch = OpenGovComponentHelper.new

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
  
  def test_components_register
    assert_equal(
                 ['PersonLocator::address','PersonLocator::person'],
                 @ch.cm.available_models.sort
                 )
  end

  def test_components_unregister
    @ch.cm.unregister_component('PersonLocator')
    assert_equal('', @ch.cm.available_models.join(''))
  end

  def test_components_get_model
    begin
      person = @ch.get_model("PersonLocator::person")
    rescue DRb::DRbServerNotFound
      fail 'Could not connect to PersonLocator component'
    end

    larry = person.new(:fname => 'Larry', :lname => 'Reaves')
    larry.save

    assert_equal('Larry', person.find_by_lname('Reaves').fname)

    larry.delete
  end

  def test_abstract_data_type
    begin
      person = @ch.get_model("PersonLocator::person")
    rescue DRb::DRbServerNotFound
      fail 'Could not connect to PersonLocator component'
    end
    larry = person.new(:fname => 'Larry', :lname => 'Reaves')
    larry.save

    larry2 = OpenGovPerson.new(larry)

    assert_equal('Larry', larry2.the_firstest_name)

    larry.delete    
  end
end
