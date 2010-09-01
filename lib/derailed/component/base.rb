require 'drb'
require 'rubygems'
require 'authlogic'
require 'daemons'

dir = File.expand_path(File.dirname(__FILE__))

[
 'authentication',
 'controller',
 'crud',
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
    # access to models.  It also provides basic CRUD functionality for all
    # models via the Derailed::Component::Crud module
    class Base
      include Authentication
      include Environment
      include Crud
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

        models, @controller = require_libraries
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
      # by default it provides CRUD functionality for the models.  To override
      # call in the component to do something besides CRUD, do a call(env,false)
      # to setup your environment, then handle the request
      def call(env, model_crud = true)
        setup_env(env)

        if model_crud then
          status, headers, body = crud(env)
        end

        # if we have a status and it's not a 404, return it
        if status && status != 404
          [status, headers, body]
        # otherwise, send it to the controller if we have one
        elsif @controller
          @controller.send(next_path)
        # or return a 404
        else
          View.not_found "No controller found for component #{@name}"
        end
      end
    end
  end
end
