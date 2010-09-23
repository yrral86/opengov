require 'authlogic'

[
 'authentication',
 'controller',
 'daemon',
 'environment',
 'loader',
 'model',
 'models',
 'view'
].each do |library|
  require "derailed/component/#{library}"
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
      include Loader
      include Models
      include View

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

        @client = ComponentClient.new

        # must be after add_models as controller creates a whitelist
        # of what can be called and that list needs to include the models
        # for CRUD to work
        @controller = controller_class.new(self, @client) if controller_class

        need = @client.dependencies_not_satisfied(@dependencies)
        if need != []
          puts 'Dependencies not met: ' + need.join(",")
        end

        Service.start @name, self
        @client.cm.register_component(@name)
        @registered = true
        at_exit {
          if @registered
            @client.cm.unregister_component(@name)
          end
          DRb.stop_service
          ActiveRecord::Base.remove_connection
        }

        self
      end

      # name returns the name of the component as set in initialize
      def name
        @name
      end

      # stop stops the daemon
      def stop
        p "component #{self..name} shutting down"
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
        if method
          @controller.send(method)
        else
          @controller.send(:index)
        end
      end
    end
    autoload :Authenticator, 'derailed/component/authenticator'
  end
end
