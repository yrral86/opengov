require 'derailed/config'
require 'derailed/servedobject'
require 'derailed/service'

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
        @key = rand(2**31)
        apis = [
                API::Manager
               ]
        @object = ServedObject.new(self, @key, apis)
        @self
      end

      def check_key(key)
        #TODO
        :private
      end

      def key=(key)
        Thread.current[:request_key] = key
      end

      def authorized?
        true
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
