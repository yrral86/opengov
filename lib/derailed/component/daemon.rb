require 'derailed/config'

module Derailed
  module Component
    # = Derailed::Component::Daemon
    # This class provides the basic daemon structure for components
    class Daemon
      # initialize stes the name, type and selects the db
      def initialize(name)
        config = read_component_config(name)
        @name = config['name']
        @component_class = Component.const_get(config['class'])
        @requirements = config['requirements']
        @db = config['db']
        @db ||= 'default'
        init_ar
        self
      end

      def run
        $0 = "OpenGov#{@name}Component"
        component_proc.call
      end

      private
      # init_ar initialize the ActiveRecord connection
      def init_ar
        conf = YAML::load(File.open(Config::RootDir + '/db/config.yml'))[@db]
        ActiveRecord::Base.establish_connection(conf[Config::Environment])
      end

      def component_proc
        proc do
          @component_class ||= Derailed::Component::Base
          @component_class.new(@name, @requirements).daemonize
        end

      end

      def read_component_config(component)
        config = YAML::load(File.open(Config::ComponentDir +
                                      "/#{component}/config.yml"))
        config['class'] ||= 'Base'
        config['requirements'] ||= []
        config
      end
    end
  end
end
