#!/usr/bin/env ruby1.8

require 'test/unit'
require 'test/unit/ui/console/testrunner'
require 'drb'

class OpenGovComponentManagerTest < Test::Unit::TestCase
  def setup
    @component_manager = DRbObject.new nil, 'drbunix://tmp/opengovcomponentmanager.sock'
  end

  def test_data_components_register_unregister
    @component_manager.register_data_component('a')
    assert_equal('a', @component_manager.list_data_components)
    
    @component_manager.register_data_component('cat')
    assert_equal('a cat', @component_manager.list_data_components)

    @component_manager.unregister_data_component('a')
    assert_equal('cat', @component_manager.list_data_components)

    @component_manager.unregister_data_component('cat')
    assert_equal('', @component_manager.list_data_components)
  end
end

Test::Unit::UI::Console::TestRunner.run(OpenGovComponentManagerTest)
