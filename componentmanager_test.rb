#!/usr/bin/env ruby1.8

require 'test/unit'
require 'test/unit/ui/console/testrunner'
require 'drb'

class OpenGovComponentManagerTest < Test::Unit::TestCase
  def setup
    `./componentmanager_control.rb start`
    @component_manager = DRbObject.new nil, 'drbunix://tmp/opengovcomponentmanager.sock'
  end

  def teardown
    `./componentmanager_control.rb stop`
  end

  def test_data_components_register_unregister
    `./personcomponent_control.rb start`
    sleep 0.3 # give the daemon time to start and register itself
    assert_equal('Person', @component_manager.list_data_components)
     
    `./personcomponent_control.rb stop`
    assert_equal('', @component_manager.list_data_components)
  end
end

Test::Unit::UI::Console::TestRunner.run(OpenGovComponentManagerTest)
