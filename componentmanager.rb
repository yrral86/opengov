#!/usr/bin/env ruby1.9.1

dir = File.expand_path(File.dirname(__FILE__))

require 'drb'
require 'drb/unix'
require 'rubygems'
require 'daemons'
require dir + '/lib/derailed'


class OpenGovComponentManager
  def initialize
    @dir = File.expand_path(File.dirname(__FILE__))
    @components = {}
    @routes = {}
    @c_mutex = Mutex.new
    @r_mutex = Mutex.new
    @self
  end

  def register_component(socket)
    component = DRbObject.new nil, socket
    @c_mutex.synchronize do
      @components[component.name] = component
    end
    register_routes(component)
  end

  def unregister_component(name)
    unregister_routes(@components[name])
    @c_mutex.synchronize do
      @components.delete(name)
    end
  end

  def register_routes(component)
    name = component.name
    new_routes = {}
    @r_mutex.synchronize do
      component.routes.each do |r|
        if @routes[r] == nil then
          new_routes[r] = DRbObject.new nil, get_component_socket(name)
        else
          raise "Route '" + r + "' already handled by component " + @routes[r].name
        end
      end
      @routes.update(new_routes)
    end
  end

  def unregister_routes(component)
    @r_mutex.synchronize do
      component.routes.each do |r|
        @routes.delete(r)
      end
    end
  end

  def available_routes
    @routes
  end

  def available_models
    models = []
    @components.each_value do |c|
      models.concat(c.model_names.collect {|n| c.name + '::' + n})
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
    DRb.start_service Derailed::Socket.get_socket_uri('ComponentManager'), self

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

