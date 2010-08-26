#!/usr/bin/env ruby1.9.1

require 'lib/types/person'
require 'lib/derailed/testcase'

class OpenGovComponentManagerTest < Derailed::TestCase
  def test_components_register
    assert_equal(
                 ['Authenticator::user',
                  'Authenticator::usersession',
                  'PersonLocator::address',
                  'PersonLocator::person'],
                 @ch.cm.available_models.sort
                 )
  end

  def test_components_unregister
    @ch.cm.unregister_component('PersonLocator')
    assert_equal(['Authenticator::user','Authenticator::usersession'],
                 @ch.cm.available_models.sort)
    @ch.cm.register_component(Derailed::Socket.get_socket_uri('PersonLocator'))
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
