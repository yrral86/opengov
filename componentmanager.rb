#!/usr/bin/env ruby1.9.1

require 'drb'
require 'drb/unix'
require 'rubygems'
require 'daemons'

class OpenGovComponentManager
  def initialize
    @components = {}
    @c_mutex = Mutex.new
    @router = DRbObject.new nil, 'drbunix://tmp/opengovrequestrouter.sock'

    DRb.start_service 'drbunix://tmp/opengovcomponentmanager.sock', self
    at_exit {
      @components.each_value do |c|
        unregister_component(c.name)
        c.unregistered
        c.stop
      end
      DRb.stop_service
    }
    @self
  end

  def register_component(socket)
    component = DRbObject.new nil, socket
    @c_mutex.synchronize do
      @components[component.name] = component
    end
    @router.register_component(component)
  end

  def unregister_component(name)
    @router.unregister_component(@components[name])
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
    if @components[name] then
        @components[name].__drburi
      else
        nil
      end
  end

  def daemonize
    DRb.thread.join
  end
end


Daemons.run_proc('OpenGovComponentManager') do
  OpenGovComponentManager.new.daemonize
end

