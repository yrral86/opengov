require 'daemons'

require 'derailed/config'
require 'derailed/manager/components'

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
      self
    end

    # self.component creates a new component type instance
    def self.component(name)
      config = read_component_config(name)
      component = new(config['name'])
      component.configure(config)
      component
    end

    # self.manager creates a new manager type instance
    def self.manager
      new('OpenGovManager', :manager)
    end

    # daemonize runs the Manager
    def daemonize
      Daemons.run_proc(@name, {:dir_mode => :normal,
                         :dir => Config::RootDir}) do
        Derailed::Manager::Interface.new.daemonize
      end
    end

    def start
      component = component_proc
      @pid = Daemonize.call_as_daemon component, nil, "OpenGov#{@name}Component"
    end

    def pid=(pid)
      @pid = pid
    end

    def stop
      Process.kill 'TERM', @pid
      @pid = nil
    end

    def restart
      stop
      start
    end

    def status
      "Component #{@name} " +
        (running? ? "running [pid #{@pid}]" : "not running")
    end

    def configure(config)
      @component_class = Component.const_get(config['class'])
      @requirements = config['requirements']
    end

    private
    # init_ar initialize the ActiveRecord connection
    def init_ar(db)
      conf = YAML::load(File.open(Config::RootDir + '/db/config.yml'))[db]
      ActiveRecord::Base.establish_connection(conf[Config::Environment])
    end

    def component_proc
      proc do
        @component_class ||= Derailed::Component::Base
        @component_class.new(@name, @requirements).daemonize
      end

    end

    def running?
      begin
        if @pid
          Process.getpgid(@pid)
        else
          false
        end
      rescue
        false
      end
    end

    def self.read_component_config(component)
      config = YAML::load(File.open(Config::ComponentDir +
                                    "/#{component}/config.yml"))
      config['class'] ||= 'Base'
      config['requirements'] ||= []
      config
    end
  end
end
