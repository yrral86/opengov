module Derailed
  module Manager
    module Registration
      # register_component is called by the component right after it sets up its
      # socket.  The component sends the manager the socket, and the manager
      # opens the socket and stores the DRbObject.  Manager then registers the
      # routes the component provides in the routes hash.
      def register_component(socket)
        component = DRbObject.new nil, socket
        @c_mutex.synchronize do
          @components[component.name] = component
        end
      end

      # unregister_component is called by the component on shutdown.  It removes
      # the component's routes and then deletes it from the component hash.
      def unregister_component(name)
        @c_mutex.synchronize do
          @components.delete(name)
        end
      end
    end
  end
end
