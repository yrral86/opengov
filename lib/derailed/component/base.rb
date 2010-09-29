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

        Util.environment_apis(@object, @key)

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

        @uri = Service.start @name, @object
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
        t = Thread.new do
          response = call(env)
          queue_response(key, response)
        end
        begin
          return [@uri, key]
        ensure
          free_response(key, t)
        end
      end

      def queue_response(key, response)
        # save response to @responses
        @responses[key] = response
        # and wake up fetch_response thread
        @keys[key].wakeup
      end
      private :queue_response

      def free_response(key, t)
      # clean up response after 10 seconds
        Thread.new do
          sleep Config::DRbTimeout
          # delete the response
          @responses.delete(key)
          # free the key and kill the response fetching thread
          @keys.free(key)
          # kill the response handling thread
          t.kill
        end
        key
      end
      private :free_response

      def fetch_response(key)
        debug "fetch_response(#{key})"
        t = Thread.new do
          if @keys.exists?(key)
            Thread.stop
            response = @responses[key]
            if response
              @responses[key] = nil
              response
            else
              View.internal_error "Key was valid, but no response found"
            end
          else
            View.not_found "RackApp requested an invalid key"
          end
        end
        @keys[key] = t
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
        key = manager.check_key(Thread.current[:request_key])
        puts "in authorized? key = #{key.inspect}"
        key == :private
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
