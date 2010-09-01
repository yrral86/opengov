require 'drb'
require 'rubygems'
require 'authlogic'
require 'daemons'

dir = File.expand_path(File.dirname(__FILE__))

[
 'authentication',
 'controller',
 'environment',
 'helpers',
 'loader',
 'model',
 'view'
].each do |library|
  require "#{dir}/#{library}"
end

module Derailed
  module Component
    # = Derailed::Component::Base
    # This class is the base of all components, and handles
    # registering/deregistering with the Manager, database initilization, and
    # access to models.
    class Base
      include Authentication
      include Environment
      include Helpers
      include View
      include Loader

      # initialize sets up the database from the config file, initializes the
      # list of models, checks for dependencies, and then registers the
      # component with the Manager
      def initialize(name, dependencies = [])
        @registered = false;
        @name = name
        @dependencies = dependencies

        models, controller_class = require_libraries
        @controller = controller_class.new(self) if controller_class

        @models = {}
        add_models(models)

        @cc = ComponentClient.new
        need = @cc.dependencies_not_satisfied(@dependencies)
        if need == [] then
          socket = Manager::Socket.uri @name
          DRb.start_service socket, self
          @cc.cm.register_component(socket)
          @registered = true
          at_exit {
            if @registered then
              @cc.cm.unregister_component(@name)
            end
            DRb.stop_service
            ActiveRecord::Base.remove_connection
          }
        else
          p 'Dependencies not met: ' + need.join(",")
          exit
        end
        self
      end

      # add_models adds the models passed to it to the component's list of
      # available models, indexed by the downcased model name
      def add_models(models)
        models.each do |m|
          m.extend(DRbUndumped)
          @models[m.name.downcase] = m
        end
      end

      # model_names returns the list of available model names (which are all
      # downcased)
      def model_names
        @models.keys
      end

      # model_types returns the list of available model types
      def model_types
        types = []
        @models.each_value do |m|
          if m.respond_to?(:abstract_type) && m.abstract_type
            types << m.abstract_type
          end
        end
        types
      end

      # model returns the requested model (name is downcased)
      def model(name)
        @models[name]
      end

      # name returns the name of the component as set in initialize
      def name
        @name
      end

      # stop stops the daemon
      def stop
        p 'component manager shutting down, exiting ' + self.class.name.to_s
        exit
      end

      # daemonize joins the DRb server thread to the main thread
      def daemonize
        DRb.thread.join
      end

      # routes returns the list of routes this component will handle.
      # The default (defined here) is simply the downcased name of the component
      def routes
        [@name.downcase]
      end

      # call handles the request.  It always sets up the environment, and
      # calls the appropriate method on the controller
      def call(env)
        setup_env(env)

        path = next_path
        # send it to the controller if we have one
        if @controller && path
          @controller.send(path)
        # or return a 404
        else
          not_found "No controller found for component #{@name}"
        end
      end
    end
  end
end
