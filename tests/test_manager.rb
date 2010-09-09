#!/usr/bin/env ruby

dir = File.expand_path(File.dirname(__FILE__))
require dir + '/../lib/derailed/testcase'

class OpenGovManagerTest < Derailed::TestCase::Unit
  def test_component_register
    assert_equal(
                 ['Authenticator::User',
                  'Authenticator::UserSession',
                  'PersonLocator::Address',
                  'PersonLocator::Person'],
                 @cc.cm.available_models.sort
                 )
  end

  def test_component_unregister
    @cc.cm.unregister_component('PersonLocator')
    assert_equal(['Authenticator::User','Authenticator::UserSession'],
                 @cc.cm.available_models.sort)
    @cc.cm.register_component(Derailed::Manager::Socket.uri('PersonLocator'))
  end

  def test_component_available_types
    assert_equal ['PersonLocator::Person'], @cc.cm.available_types
  end

  def test_component_get_model
    begin
      person = @cc.get_model("PersonLocator::Person")
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
      person = @cc.get_model("PersonLocator::Person")
    rescue DRb::DRbServerNotFound
      fail 'Could not connect to PersonLocator component'
    end
    larry = person.new(:fname => 'Larry', :lname => 'Reaves')
    larry.save

    larry2 = Derailed::Type::Person.new(larry)

    assert_equal(larry[:id], larry2[:id])
    assert_equal(larry.fname, larry2.first_name)
    assert_equal(larry.lname, larry2.last_name)

    larry.delete
  end
end
