#!/usr/bin/env ruby1.8

require 'drb'
require 'drb/unix'

class OpenGovComponentManager
  def initialize
    @components = {}
    @c_mutex = Mutex.new
  end

  def register_component(socket)
    @c_mutex.synchronize do
      component = DRbObject.new nil, socket
      @components[component.name] = component
    end
  end

  def unregister_component(name)
    @c_mutex.synchronize do
      @components.delete(name)
    end
  end

  def available_models
    models = []
    @components.each_value do |c|
      models = c.model_names.collect {|n| c.name + '::' + n}
    end
    models
  end

  def get_model(name)
    component, model = name.split '::'
    @components[component].model(model)
  end

  def get_component_socket(name)
    @components[name].__drburi
  end
end

DRb.start_service 'drbunix://tmp/opengovcomponentmanager.sock', OpenGovComponentManager.new

at_exit { DRb.stop_service }

DRb.thread.join
