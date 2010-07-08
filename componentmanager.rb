#!/usr/bin/env ruby1.9.1

dir = File.expand_path(File.dirname(__FILE__))

require 'drb'
require 'drb/unix'
require 'rubygems'
require 'daemons'

class OpenGovComponentManager
  def initialize
    @dir = File.expand_path(File.dirname(__FILE__))
    @components = {}
    @c_mutex = Mutex.new
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

  def available_components
    @components.keys
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
    @router = DRbObject.new nil, 'drbunix://tmp/opengovrequestrouter.sock'

    DRb.start_service 'drbunix://tmp/opengovcomponentmanager.sock', self
    
    component_list = File.read(@dir + '/config/components').split "\n"
    
    component_list.each do |c|
      unless c == '' then
        `#{@dir}/components/#{c}.rb start`
      end
    end

    at_exit {
      component_list.each do |c|
        unless c == '' then
          `#{@dir}/components/#{c}.rb stop`
        end
      end
      DRb.stop_service
    }
    
    DRb.thread.join
  end
end

cm = OpenGovComponentManager.new

Daemons.run_proc('OpenGovComponentManager',
                 {:dir_mode => :normal, :dir => dir}) do
  cm.daemonize
end

