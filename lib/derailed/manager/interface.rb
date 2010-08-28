dir = File.expand_path(File.dirname(__FILE__))

require dir + '/components'
require dir + '/information'
require dir + '/mux'
require dir + '/registration'
require dir + '/socket'

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
        @components = {}
        @routes = {}
        @c_mutex = Mutex.new
        @r_mutex = Mutex.new
        @self
      end

      # daemonize starts the DRb service, reads the components to start from the
      # config file, and starts the components.
      def daemonize
        DRb.start_service Socket.uri('Manager'), self

        dir = Config::RootDir

        component_file = File.read(dir + '/config/components')
        component_list = component_file.split "\n"

        component_list.each do |c|
          unless c == '' then
          `#{dir}/components/#{c}.rb start`
          end
        end

        at_exit {
          component_list.each do |c|
            unless c == '' then
              `#{dir}/components/#{c}.rb stop`
            end
          end
          DRb.stop_service
        }

        DRb.thread.join
      end
    end
  end
end
