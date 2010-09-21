require 'drb'
require 'drb/timeridconv'

require 'derailed/config'

[
 'components',
 'information',
 'mux',
 'registration',
 'socket'
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
        @components = {}
        @daemons = {}
        @c_mutex = Mutex.new
        @self
      end

      # daemonize starts the DRb service, reads the components to start from the
      # config file, and starts the components.
      def daemonize
        DRb.install_id_conv DRb::TimerIdConv.new(10)
        DRb.start_service Socket.uri('Manager'), self

        old_dir = Dir.pwd
        Dir.chdir Config::ComponentDir
        component_list = Dir.glob '*'
        Dir.chdir old_dir

        component_list.each do |c|
          init_component c
          component_command c, 'start'
        end

        at_exit {
          component_list.each do |c|
            unless c == ''
              component_command c, 'stop'
            end
          end
          DRb.stop_service
        }

        DRb.thread.join
      end
    end
  end
end
