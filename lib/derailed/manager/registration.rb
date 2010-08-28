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
        register_routes(component)
      end

      # unregister_component is called by the component on shutdown.  It removes
      # the component's routes and then deletes it from the component hash.
      def unregister_component(name)
        unregister_routes(@components[name])
        @c_mutex.synchronize do
          @components.delete(name)
        end
      end

      # register_routes addes the routes for a given component to the routes
      # hash. Routes are {'url1'=>DRbObject1, 'url2'=> DRbObject2}
      def register_routes(component)
        name = component.name
        new_routes = {}
        @r_mutex.synchronize do
          component.routes.each do |r|
            if @routes[r] == nil then
              new_routes[r] = DRbObject.new nil, get_component_socket(name)
            else
              raise "Route '#{r}' already handled by component #{@routes[r].name}"
            end
          end
          @routes.update(new_routes)
        end
      end

      # unregister_routes removes a component's routes from the routes hash
      def unregister_routes(component)
        @r_mutex.synchronize do
          component.routes.each do |r|
            @routes.delete(r)
          end
        end
      end
    end
  end
end
