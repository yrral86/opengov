#!/usr/bin/env ruby1.8

require 'test/unit'
require 'test/unit/ui/console/testrunner'
require 'lib/componenthelper'

class OpenGovComponentManagerTest < Test::Unit::TestCase
  def setup
    `./componentmanager_control.rb start`
    `./personcomponent_control.rb start`
    sleep 0.3 # give the daemons time to start and register themselves
    @ch = OpenGovComponentHelper.new
  end

  def teardown
    `./personcomponent_control.rb stop` # in case an assert fails
    `./componentmanager_control.rb stop`
  end

  def test_data_components_register_unregister
    assert_equal('Person', @ch.cm.list_data_components)

    person = @ch.get_model("Person")

    larry = person.new(:fname => 'Larry', :lname => 'Reaves')
    larry.save

    assert_equal('Larry', person.find_by_lname('Reaves').fname)

    larry.delete
     
    `./personcomponent_control.rb stop`
    assert_equal('', @ch.cm.list_data_components)
  end
end

Test::Unit::UI::Console::TestRunner.run(OpenGovComponentManagerTest)
