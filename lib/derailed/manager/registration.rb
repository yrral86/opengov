module Derailed
  module Manager
    # = Derailed::Manager::Registration
    # This module provides registrations and unregsitration functions
    # that components call on setup and shutdown.
    module Registration
      # register_component is called by the component right after it sets up its
      # socket.  The component sends the manager its name and the Manager passes
      # the socket URI to the Daemon controller class
      def register_component(name)
        @components[name].proxy = name
      end

      # unregister_component is called by the component on shutdown.  It simply
      # deletes the component from the component hash.
      def unregister_component(name)
        @components[name].proxy = nil
      end
    end
  end
end
