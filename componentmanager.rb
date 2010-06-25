#!/usr/bin/env ruby1.8

require 'drb'
require 'drb/unix'

class OpenGovComponentManager
  def initialize
    @data_components = {}
    @view_components = {}
    @dc_mutex = Mutex.new
    @vc_mutex = Mutex.new
  end

  def register_data_component(socket)
    @dc_mutex.synchronize do
      component = DRbObject.new nil, socket
      @data_components[component.model_name] = component
    end
  end

  def register_view_component(socket)
    @vc_mutex.synchronize do
      component = DRbObject.net nil, socket
      @view_components[component.model_name] = component
    end
  end

  def unregister_data_component(name)
    @dc_mutex.synchronize do
      @data_components.delete(name)
    end
  end

  def unregister_view_component(name)
    @vc_mutex.synchronize do
      @view_components.delete(name)
    end
  end

  def list_data_components
    @data_components.keys.join(" ")
  end

  def list_view_components
    @view_components.keys.join(" ")
  end

  def get_data_component_model(name)
    @data_components[name].model
  end
end

DRb.start_service 'drbunix://tmp/opengovcomponentmanager.sock', OpenGovComponentManager.new

at_exit { DRb.stop_service }

DRb.thread.join
