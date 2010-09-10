require 'drb'
require 'drb/timeridconv'
require 'rubygems'
require 'authlogic'
require 'daemons'

dir = File.expand_path(File.dirname(__FILE__))

[
 'authentication',
 'controller',
 'environment',
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

        @models = {}
        add_models(models)

        # must be after add_models as controller creates a whitelist
        # of what can be called and that list needs to include the models
        # for CRUD to work
        @controller = controller_class.new(self) if controller_class

        @cc = ComponentClient.new
        need = @cc.dependencies_not_satisfied(@dependencies)
        if need == [] then
          socket = Manager::Socket.uri @name
          DRb.install_id_conv DRb::TimerIdConv.new(10)
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
      # available models, indexed by the model name
      def add_models(models)
        models.each do |m|
          m.extend(DRbUndumped)
          @models[m.name] = m
        end
      end

      # model_names returns the list of available model names
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

      # has_type? returns true if the component provides the given type,
      # false otherwise
      def has_type?(type)
        model_types.include?(type)
      end

      # model returns the requested model
      def model(name)
        puts @models.inspect
        @models[name]
      end

      # model_by_url returns the requested model
      def model_by_url(model_url)
        @models.keys.each do |k|
          if k.downcase == model_url
            return @models[k]
          end
        end
      end

      # def clear_models destroys all records if we are
      # in the test environment
      def clear_models
        if Config::Environment == 'test'
          @models.values.each do |m|
            puts m.name
            unless @name == 'Authenticator' && m.name == 'UserSession'
              m.destroy_all
            end
          end
        else
          throw "clear_models called in non-test environment"
        end
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
      # The default (defined here) is simply the downcased name of the
      # component
      def routes
        [@name.downcase]
      end

      # call handles the request.  It sets up the environment, and
      # calls the appropriate method on the controller.  The method it calls
      # defaults to next_path, but if a value is passed in for path_position
      # it grabs that part of the path as the method name.
      def call(env, path_position=nil)
        setup_env(env)
        method = path_position ? path(path_position) : next_path
        @controller.send(method)
      end
    end
  end
end
