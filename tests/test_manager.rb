#!/usr/bin/env ruby

require 'derailed/testcase'

class OpenGovManagerTest < Derailed::TestCase
  def test_component_register
    assert_equal(
                 ['Authenticator::User',
                  'Authenticator::UserSession',
                  'Map::Location',
                  'Map::Map',
                  'Map::MapLocation',
                  'Messenger::Message',
                  'PersonLocator::Address',
                  'PersonLocator::Person'],
                 sort_models
                 )
  end

  def test_component_unregister
    @manager.unregister_component('PersonLocator')
    assert_equal(['Authenticator::User',
                  'Authenticator::UserSession',
                  'Map::Location',
                  'Map::Map',
                  'Map::MapLocation',
                  'Messenger::Message'],
                 sort_models)
    @manager.register_component('PersonLocator')
  end

  def test_component_stop_start
    orig_components = sort_components
    orig_components.each do |component|
      @manager.component_command(component.downcase,'stop')
      new_components = sort_components
      assert_equal [component], orig_components - new_components

      @manager.component_command(component.downcase,'start')
      new_components = sort_components
      assert_equal orig_components, new_components
    end
  end

  def sort_components
    @manager.available_components.sort
  end

  def sort_models
    @manager.available_models.sort
  end

  def test_component_available_types
    assert_equal ['PersonLocator::Person'], @manager.available_types
  end

  def test_component_get_model
    begin
      person = Derailed::Service.get_model('PersonLocator::Person')
    rescue DRb::DRbServerNotFound
      fail 'Could not connect to PersonLocator component'
    end

    bob = person.new(:fname => 'Bob', :lname => 'Smith')
    bob.save

    assert_equal('Bob', person.find_by_lname('Smith').fname)

    bob.delete
  end

  def test_abstract_data_type
    begin
      person = Derailed::Service.get_model("PersonLocator::Person")
    rescue DRb::DRbServerNotFound
      fail 'Could not connect to PersonLocator component'
    end
    bob = person.new(:fname => 'Bob', :lname => 'Smith')
    bob.save

    abob = Derailed::Type::Person.new(bob)

    assert_equal(bob[:id], abob[:id])
    assert_equal(bob.fname, abob.first_name)
    assert_equal(bob.lname, abob.last_name)

    bob.delete
  end
end
