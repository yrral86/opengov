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
      def initialize(name, apis, dependencies)
        @registered = false;
        @name = name
        @dependencies = dependencies
        apis << API::Base
        @keys = Keys.new
        @key = @keys.gen
        @responses = {}

        @object = ServedObject.new(self, @key, apis)
        @object.register_api(@key,
                             API::Testing) if Config::Environment == 'test'

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

        Service.start @name, @object
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

      # name returns the name of the component as set in initialize
      def name
        @name
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

      def request_response(env)
        key = @keys.gen
        Thread.new do
          response = call(env)
          queue_response(key, response)
        end
      # clean up response after 10 seconds
        Thread.new do
          sleep 10
          reap_response(key)
        end
        key
      end

      def queue_response(key, response)
        @responses[key] = response
      end
      private :queue_response

      def reap_response(key)
        @responses.delete(key)
      end
      private :reap_response

      def fetch_response(key)
        t = Thread.new do
          if @keys.exists?(key)
            @responses[key]
          else
            View.not_found "RackApp requested an invalid key"
          end
        end
        # store t somewhere so we can wake it in queue response
        t.value
      end

      def debug(msg)
        puts msg
      end

      def key=(key)
        Thread.current[:request_key] = key
      end

      def authorized?
        manager = Service.get('Manager')
        manager.check_key(Thread.current[:request_key]) == :private
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
