require 'derailed/config'

module Derailed
  module Component
    # = Derailed::Component::Daemon
    # This class provides the basic daemon structure for components
    class Daemon
      # initialize processes the configuration file and initializes
      # ActiveRecord
      def initialize(name)
        @config = read_component_config(name)
        init_ar
        self
      end

      # run sets the process name and runs the component
      def run
        $0 = "OpenGov#{name}Component"
        class_object.new(name, requirements).daemonize
      end

      private
      # init_ar initialize the ActiveRecord connection
      def init_ar
        conf = YAML::load(File.open(Config::RootDir + '/db/config.yml'))[db]
        ActiveRecord::Base.establish_connection(conf[Config::Environment])
      end

      # read_component_config reads the config file and sets some defaults
      def read_component_config(component)
        config = YAML::load(File.open(Config::ComponentDir +
                                      "/#{component}/config.yml"))
        config['requirements'] ||= []
        config['db'] ||= 'default'
        config['class'] ||= 'Base'
        config['class_object'] = Component.const_get(config['class'])
        config
      end

      # method_missing provides a convient way to access @config
      def method_missing(id)
        @config[id.to_s] || super
      end
    end
  end
end
