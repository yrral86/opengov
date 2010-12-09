module Derailed
  module Component
    # = Derailed::Component::Daemon
    # This class provides the basic daemon structure for components
    # TODO: drop this... reincorporate into Base as we have come full circle
    # run is basically daemonize, init just parses config and connects to the
    # db (which we should conditionalize on implementing API::Models)
    class Daemon
      # initialize processes the configuration file and initializes
      # ActiveRecord
      def initialize(name)
        @config = Config.component_config(name)
        @config['logger'] = Logger.new name
        @config['class_object'] = Component.const_get(@config['class'])
        @config['api_modules'] = apis.map {|api| API.const_get(api)}
        init_ar
        self
      end

      # run sets the process name and runs the component
      def run
        $0 = "OpenGov#{name}Component"
        class_object.new(@config).daemonize
      end

      private
      # init_ar initialize the ActiveRecord connection
      def init_ar
        config = Config.db_config(db)
        Model.logger = @config['logger']
        Model.establish_connection(config)
      end

      # method_missing provides a convient way to access @config
      def method_missing(id)
        @config[id.to_s] || super
      end
    end
  end
end
