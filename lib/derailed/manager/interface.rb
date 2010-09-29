require 'derailed/config'
require 'derailed/keys'
require 'derailed/util'
require 'derailed/served_object'
require 'derailed/service'
require 'derailed/component/view'

[
 'component',
 'components',
 'information',
 'mux',
 'registration'
].each do |library|
  require "derailed/manager/#{library}"
end

module Derailed
  module Manager
    # = Derailed::Manager::Interface
    # This class manages components.  New components register themselves with
    # a manager, and the manager provides information about what
    # components/models/views are available.  It also can provide the socket
    # URIs for the components.
    class Interface
      include Mux
      include Information
      include Components
      include Registration

      # initialize creates empty hashes for the components and routes, and a
      # mutex for each hash
      def initialize
        Component.create_spawner(self)
        @components = {}
        @keys = Keys.new
        @key = @keys.gen
        apis = [
                API::Manager,
                API::RackRequestHandler
               ]
        @object = ServedObject.new(self, @key, apis)
        Util.environment_apis(@object, @key)
        @authenticator = Service.get 'Authenticator'
        @self
      end

      def check_key(key)
        #TODO
        :private
      end

      def key=(key)
        Thread.current[:request_key] = key
      end

      # TODO: Doh
      def authorized?
        true
      end

      # env -> uri, key
      def request_response(env)
        @routes ||= available_routes
        authenticate(env) do
          component = env[:controller].next
          if @routes[component] == nil
            # special case, uri = 404
            [404, "Component #{component} not found"]
          else
            @routes[component].call(env)
          end
        end
      end

      def authenticate(env)
        if @authenticator.current_session(env) or
            env[:controller].request.path == '/login'
          yield
        else
          path = env[:controller].request.path
          env[:controller].session[:onlogin] =
            path unless path == '/favicon.ico'
          @routes['login'].call(env)
        end
      end
      private :authenticate

      def name
        'Manager'
      end

      def debug(msg)
        puts msg
      end

      # daemonize starts the service, reads the components-enaled directory,
      # and starts the components.
      def daemonize
        Service.start 'Manager', @object

        old_dir = Dir.pwd
        Dir.chdir Config::ComponentDir
        component_list = Dir.glob '*'
        Dir.chdir old_dir

        component_list.each do |c|
          init_component c
          component_command c, 'start', true
        end

        at_exit {
          component_list.each do |c|
            unless c == ''
              component_command c, 'stop'
            end
          end
          Service.stop
        }

        Service.join
      end
    end
  end
end
