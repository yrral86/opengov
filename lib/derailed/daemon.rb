require 'daemons'

require 'derailed/config'

module Derailed
  # = Derailed::Daemon
  # This class provides the basic daemon structure for components and the
  # Manager
  class Daemon
    # initialize stes the name, type and selects the db
    def initialize(name, type=:component, db='default')
      @name = name
      @type = type

      if type == :component
        require 'derailed'
        init_ar(db)
      else
        require 'derailed/manager/interface'
      end
    end

    # self.component creates a new component type instance
    def self.component(name)
      new(name)
    end

    # self.manager creates a new manager type instance
    def self.manager
      new('OpenGovManager', :manager)
    end

    # daemonize runs the given block as a daemon, or if no block is given,
    # instantiates a new instance of klass and calls daemonize on that instance
    def daemonize(klass=nil,requirements=[])
      name = @type == :component ? "OpenGov#{@name}Component" : @name
      Daemons.run_proc(name, {:dir_mode => :normal, :dir => Config::RootDir}) do
        if @type == :manager
           Derailed::Manager::Interface.new.daemonize
        else
          klass ||= Derailed::Component::Base
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
