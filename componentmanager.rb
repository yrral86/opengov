#!/usr/bin/env ruby1.8

require 'drb'
require 'drb/unix'

class OpenGovComponentManager
  def initialize
    @data_components = []
    @view_components = []
    @dc_mutex = Mutex.new
    @vc_mutex = Mutex.new
  end

  def register_data_component(socket)
    @dc_mutex.synchronize do
      @data_components << component
    end
  end

  def register_view_component(socket)
    @vc_mutex.synchronize do
      @view_components << component
    end
  end

  def unregister_data_component(socket)
    @dc_mutex.synchronize do
      @data_components.delete(socket)
    end
  end

  def unregister_view_component(socket)
    @vc_mutex.synchronize do
      @view_components.delete(socket)
    end
  end

  def list_data_components
    @data_components.join(" ")
  end

  def list_view_components
    @view_components.join(" ")
  end
end

DRb.start_service 'drbunix://tmp/opengovcomponentmanager.sock', OpenGovComponentManager.new

trap("INT") { DRb.stop_service }

DRb.thread.join
