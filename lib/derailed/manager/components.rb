module Derailed
  module Manager
    # = Derailed::Manager::Components
    # This module provides functions for accessing the components and their
    # models.
    module Components
      # get_model returns a DRbObject representing the given model
      def get_model(name)
        component, model = name.split '::'
        @components[component].model(model)
      end

      # get_component_socket returns the socket URI for the named Component
      def get_component_socket(name)
        if @components[name]
          @components[name].__drburi
        else
          nil
        end
      end

      def component_command(component, command, async = false)
        if command == 'start'
          @daemons[component].send command, async
        else
          @daemons[component].send command
        end
      end

      def init_component(component)
        @daemons[component] = Daemon.new(component)
      end

      def component_pid(component, pid)
        @daemons[component].pid = pid
      end
    end
  end
end
