require 'drb'
require 'drb/unix'
require 'rubygems'
require 'active_record'
require 'authlogic'
require 'daemons'
require 'rack/request'
require 'rack/logger'

dir = File.expand_path(File.dirname(__FILE__))

[
 'authentication',
 'controller',
 'crud',
 'helpers',
 'model',
 'view'
].each do |library|
  require "#{dir}/#{library}"
end

module Derailed
  module Component
    # = Derailed::Component::Base
    # This class is the base of all components, and handles
    # registering/deregistering with the ComponentManager, database
    # initialization, and access to models.  It also provides basic CRUD
    # functionality for all models via the Derailed::Component::Crud module
    class Base
      include Authentication
      include Controller
      include Crud
      include Helpers
      include View

      # initialize sets up the database from the config file, initializes the
      # list of models, checks for dependencies, and then registers the
      # component with the ComponentManager
      def initialize(name, models, views, dependencies = [], db = 'default')
        @registered = false;
        db_config = YAML::load(File.open(Config::RootDir + '/db/config.yml'))[db]
        ActiveRecord::Base.logger = Logger.new STDOUT
        ActiveRecord::Base.establish_connection(db_config[Config::Environment])
        @name = name
        @dependencies = dependencies

        @models = {}

        add_models(models)

        #    not yet used
        #    @views = {}
        #    views.each do |v|
        #      @views[v.name.downcase] = v
        #    end


        @cc = ComponentClient.new
        need = @cc.dependencies_not_satisfied(@dependencies)
        if need == [] then
          socket = Socket.uri @name
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
          crud(env)
        end
      end
    end
  end
end
