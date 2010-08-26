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
 'model',
 'view'
].each do |library|
  require "#{dir}/#{library}"
end

module Derailed
  module Component
    class Base
      include Authentication
      include Controller
      include Crud

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


        @ch = ComponentHelper.new
        need = @ch.dependencies_not_satisfied(@dependencies)
        if need == [] then
          socket = Socket.get_socket_uri @name
          DRb.start_service socket, self
          @ch.cm.register_component(socket)
          @registered = true
          at_exit {
            if @registered then
              @ch.cm.unregister_component(@name)
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

      def add_models(models)
        models.each do |m|
          m.extend(DRbUndumped)
          @models[m.name.downcase] = m
        end
      end

      def unregistered
        @registered = false
      end

      def model_names
        @models.keys
      end

      def model(name)
        @models[name]
      end

      def name
        @name
      end

      def stop
        p 'component manager shutting down, exiting ' + self.class.name.to_s
        # need to figure out magic to properly kill daemon
      end

      def daemonize
        DRb.thread.join
      end

      def routes
        [@name.downcase]
      end

      def call(env, model_crud = true)
        setup_env(env)

        if model_crud then
          crud(env)
        end
      end
    end
  end
end
