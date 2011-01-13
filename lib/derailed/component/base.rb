require 'authlogic'

[
 'authentication',
 'controller',
 'daemon',
 'environment',
 'loader',
 'model',
 'model_proxy',
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

      attr_reader :name, :logger

      # initialize sets up the database from the config file, initializes the
      # list of models, checks for dependencies, and then registers the
      # component with the Manager
      def initialize(config)#(name, apis, dependencies)
        @registered = false;
        @logger = config['logger']
        @name = config['name']
        @dependencies = config['dependencies']
        config['api_modules'] << API::Base
        @keys = Keys.new
        @served_key = @keys.gen
        @responses = {}

        @served_object = ServedObject.new(self,
                                          @served_key, config['api_modules'])

        # allow special methods in development and testing environments
        Util.environment_apis(@served_object, @served_key)

        models, controller_class = require_libraries

        @models = {}
        add_models(models)

        @authenticator = Service.get 'Authenticator'
        @manager = Service.get 'Manager'

        # must be after add_models as controller creates a whitelist
        # of what can be called and that list needs to include the models
        # for CRUD to work
        @controller = controller_class.new(self, @manager) if controller_class

#        need = @client.dependencies_not_satisfied(@dependencies)
#        if need != []
#          puts 'Dependencies not met: ' + need.join(",")
#        end

        @uri = Service.start @name, @served_object
        @manager.register_component(@name)
        @registered = true
        at_exit {
          if @registered
            @manager.unregister_component(@name)
          end
          Service.stop
          ActiveRecord::Base.remove_connection
        }

        self
      end

      # daemonize joins the DRb server thread to the main thread
      def daemonize
        Service.join
      end

      # routes returns the list of routes this component will handle.
      # The default (defined here) is simply the downcased name of the
      # component
      def routes
        [@name.downcase]
      end

      def debug(msg)
        puts msg
      end

      # TODO here and interface
      def allowed?(key, id)
        key = @manager.check_key(key)
        key == :private
      end

      # TODO
      def authorized_methods(key, public_methods, manager_methods)
        manager_methods
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
