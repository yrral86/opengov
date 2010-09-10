require 'derailed'

module Derailed
  # = Derailed::Daemon
  # This class provides the basic daemon structure for components and the
  # Manager
  class Daemon
    Component = 0
    Manager = 1

    # initialize stes the name, type and selects the db
    def initialize(name, type=Component, db='default')
      @name = name
      @type = type

      if type == Component
        init_ar(db)
      end
    end

    # self.component creates a new component type instance
    def self.component(name)
      new(name)
    end

    # self.manager creates a new manager type instance
    def self.manager
      new('OpenGovManager', Manager)
    end

    # daemonize runs the given block as a daemon, or if no block is given,
    # instantiates a new instance of klass and calls daemonize on that instance
    def daemonize(klass=Derailed::Component::Base,requirements=[])
      name = @type == Component ? "OpenGov#{@name}Component" : @name
      Daemons.run_proc(name, {:dir_mode => :normal, :dir => Config::RootDir}) do
        if block_given?
          yield
        else # assumes component, because manager has a block
          klass.new(@name, requirements).daemonize
        end
      end
    end

    private
    # init_ar initialize the ActiveRecord connection
    def init_ar(db)
      conf = YAML::load(File.open(Config::RootDir + '/db/config.yml'))[db]
      ActiveRecord::Base.establish_connection(conf[Config::Environment])
    end
  end
end
