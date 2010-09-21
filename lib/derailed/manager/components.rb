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

      def self.read_component_config(name)
        config = YAML::load(File.open(Derailed::Config::ComponentDir +
                                      "/#{name}/config.yml"))
        config['class'] ||= 'Base'
        config['requirements'] ||= []
        config
      end
    end
  end
end
