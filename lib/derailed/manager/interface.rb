[
 'config',
 'logger',
 'keys',
 'util',
 'served_object',
 'service'
].each do |library|
  require "derailed/#{library}"
end

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

      attr_reader :logger

      # initialize creates empty hashes for the components and routes, and a
      # mutex for each hash
      def initialize
        @logger = Logger.new 'Manager', true
        Component.create_spawner(self)
        @components = {}
        @responses = {}
        @keys = Keys.new
        @key = @keys.gen
        apis = [
               API::Manager
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

      def name
        'Manager'
      end

      def debug(msg)
        puts msg
      end

      def allowed?(key, id)
        # TODO: check if key for served_object request is allowed
        true
      end

      def authorized_methods(key, public_methods, manager_methods)
        manager_methods
      end

      # daemonize starts the service, reads the components-enaled directory,
      # and starts the components.
      def daemonize
        Service.start 'Manager', @object

        register_signals

        old_dir = Dir.pwd
        Dir.chdir Config::ComponentDir
        component_list = Dir.glob '*'
        Dir.chdir old_dir

        component_list.each do |c|
          init_component c
          component_command c, 'start', true
        end

        Service.join
      end

      def register_signals
        @exiting = false

        at_exit {
          @exiting = true
          @components.each_value do |c|
            c.stop
          end
          Service.stop
        }

        Signal.trap('CHLD') do
          Process.wait
          @components.each_value do |c|
            if !c.running? && c.registered?
              c.died @exiting
            end
          end
        end
      end
    end
  end
end
