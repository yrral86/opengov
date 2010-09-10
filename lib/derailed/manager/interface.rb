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
        component_list = resolve_dependencies(Dir.glob '*')
        Dir.chdir old_dir

        component_list.each do |c|
          `#{Config::RootDir}/control.rb -c #{c} start`
        end

        at_exit {
          component_list.each do |c|
            unless c == '' then
              `#{Config::RootDir}/control.rb -c #{c} stop`
            end
          end
          DRb.stop_service
        }

        DRb.thread.join
      end

      private

      # resolve_dependencies should reorder the components based on dependencies
      # so that they can start in that order.
      def resolve_dependencies(array)
        # hax for now- put static first
        new_array = ['static']
        array.each do |c|
          new_array.push(c) unless c == 'static'
        end
        new_array
      end
    end
  end
end
