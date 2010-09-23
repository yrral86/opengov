module Derailed
  module Manager
    # = Derailed::Manager::Information
    # This module provides functions to request information from the Manager
    module Information
      # available_routes returns the routes hash built by scanning
      # collecting the routes from each component.
      def available_routes
        routes = {}
        @daemons.each_value do |c|
          c.proxy.routes.each do |r|
            if routes[r] == nil
              routes[r] = c.proxy
            else
              raise "Route '#{r}' already handled by component " +
                routes[r].name
            end
          end if c.registered?
        end
        routes
      end

      # available_models returns a list of all models provided by registered
      # components.  Model names are ComponentName::ModelName
      # (CamelCase::CamelCase)
      def available_models
        gather do |c|
          c.model_names
        end
      end

      # available_types returns a list of all abstract data types the
      # components can provide... we only allow one model of each type per
      # component.  Type names are ComponentName::TypeName
      # (CamelCase::CamelCase)
      def available_types
        gather do |c|
          c.model_types
        end
      end

      # components_with_type returns a list of components that can supply the
      # type specified
      def components_with_type(type)
        array = []
        @daemons.each_value do |c|
          array << c.proxy.name if c.proxy.has_type?(type)
        end
        array
      end

      # available_components returns a list of all registered components
      def available_components
        components = []
        @daemons.each_key do |k|
          components << k if @daemons[k].registered?
        end
        components
      end
    end
  end
end
