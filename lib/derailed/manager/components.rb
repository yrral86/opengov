module Derailed
  module Manager
    # = Derailed::Manager::Components
    # This module provides functions for accessing the components and their
    # models.
    module Components
      # get_model returns a DRbObject representing the given model
      def get_model(name)
        component, model = name.split '::'
        @daemons[component].proxy.model(model)
      end

      def component_command(component, command, async = false)
        component = component_by_lowercase_name(component)
        if command == 'start'
          component.send command, async
        else
          component.send command
        end
      end

      def component_pid(component, pid)
        component_by_lowercase_name(component).pid = pid
      end

      private
      def init_component(component)
        daemon = Daemon.new(component)
        @daemons[daemon.name] = daemon
      end

      def component_by_lowercase_name(name)
        @daemons.each_key do |k|
          return @daemons[k] if k.downcase == name
        end
        nil
      end
    end
  end
end
