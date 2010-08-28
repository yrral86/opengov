dir = File.expand_path(File.dirname(__FILE__))

require dir + '/socket'

module Derailed
  module Manager
    # = Derailed::Manager::Interface
    # This class manages components.  New components register themselves with
    # a manager, and the manager provides information about what
    # components/models/views are available.  It also can provide the socket
    # URIs for the components.
    class Interface
      # initialize creates empty hashes for the components and routes, and a
      # mutex for each hash
      def initialize
        @components = {}
        @routes = {}
        @c_mutex = Mutex.new
        @r_mutex = Mutex.new
        @self
      end

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

      # available_routes returns the routes hash
      def available_routes
        @routes
      end

      # available_models returns a list of all models provided by registered
      # components.  Model names are ComponentName::modelname
      # (CamelCase::downcase)... I can't think of any reason not to get it
      # working with CamelCase though for consistency
      def available_models
        models = []
        @components.each_value do |c|
          models.concat(c.model_names.collect {|n| "#{c.name}::#{n}"})
        end
        models
      end

      # available_types returns a list of all abstract data types the components
      # can provide... we only allow one model for each type per component.
      # Type names are ComponentName::TypeName (CamelCase::CamelCase)
      def available_types
        types = []
        @components.each_value do |c|
          types.concat(c.model_types.collect {|n| "#{c.name}::#{n}"})
        end
        types
      end

      # available_components returns a list of all registered components
      def available_components
        @components.keys
      end

      # get_model returns a DRbObject representing the given model
      def get_model(name)
        component, model = name.split '::'
        @components[component].model(model)
      end

      # get_component_socket returns the socket URI for the named Component
      def get_component_socket(name)
        if @components[name] then
          @components[name].__drburi
        else
          nil
        end
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
