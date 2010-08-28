#!/usr/bin/env ruby1.9.1

require 'lib/derailed/testcase'

class OpenGovComponentManagerTest < Derailed::TestCase
  def test_components_register
    assert_equal(
                 ['Authenticator::user',
                  'Authenticator::usersession',
                  'PersonLocator::address',
                  'PersonLocator::person'],
                 @cc.cm.available_models.sort
                 )
  end

  def test_components_unregister
    @cc.cm.unregister_component('PersonLocator')
    assert_equal(['Authenticator::user','Authenticator::usersession'],
                 @cc.cm.available_models.sort)
    @cc.cm.register_component(Derailed::Socket.uri('PersonLocator'))
  end

  def test_components_get_model
    begin
      person = @cc.get_model("PersonLocator::person")
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
      person = @cc.get_model("PersonLocator::person")
    rescue DRb::DRbServerNotFound
      fail 'Could not connect to PersonLocator component'
    end
    larry = person.new(:fname => 'Larry', :lname => 'Reaves')
    larry.save

    larry2 = Derailed::Type::Person.new(larry)

    assert_equal(larry.id, larry2.id)
    assert_equal(larry.fname, larry2.first_name)
    assert_equal(larry.lname, larry2.last_name)

    larry.delete
  end
end
