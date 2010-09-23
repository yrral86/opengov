module Derailed
  module Manager
    # = Derailed::Manager::Components
    # This module provides functions for controlling the components.
    module Components
      def component_command(component, command, async = false)
        component = component_by_lowercase_name(component)
        if command == 'start'
          component.send command, async
        else
          component.send command
        end
      end

      # component_pid sets the pid for the component
      def component_pid(component, pid)
        component_by_lowercase_name(component).pid = pid
      end

      private
      # init_component creates a new Manager::Daemon for the component
      # and adds it to the @daemons array
      def init_component(component)
        daemon = Daemon.new(component)
        @daemons[daemon.name] = daemon
      end

      # component_by_lowercase_name returns the component who's downcased name
      # matches the name passed in
      def component_by_lowercase_name(name)
        @daemons.each_key do |k|
          return @daemons[k] if k.downcase == name
        end
        nil
      end
    end
  end
end
