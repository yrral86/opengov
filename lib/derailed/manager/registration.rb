module Derailed
  module Manager
    # = Derailed::Manager::Registration
    # This module provides registrations and unregsitration functions
    # that components call on setup and shutdown.
    module Registration
      # register_component is called by the component right after it sets up its
      # socket.  The component sends the manager the socket URI, and the manager
      # opens the socket and stores the DRbObject
      def register_component(socket)
        component = DRbObject.new nil, socket
        @c_mutex.synchronize do
          @components[component.name] = component
        end
      end

      # unregister_component is called by the component on shutdown.  It simply
      # deletes the component from the component hash.
      def unregister_component(name)
        @c_mutex.synchronize do
          @components.delete(name)
        end
      end

      # is_registered? checks if the name is registered as a component
      def is_registered?(name)
        @components.each_key do |k|
          return true if k == name || k.downcase == name
        end
        return false
      end
    end
  end
end
