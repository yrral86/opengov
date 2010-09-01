dir = File.expand_path(File.dirname(__FILE__))
require dir + '/../derailed'

module Derailed
  class Daemon
    Component = 0
    Manager = 1

    def initialize(name, type=Component, db='default')
      @name = name
      @type = type

      if type == Component
        init_ar(db)
      end
    end

    def self.component(name)
      new(name)
    end

    def self.manager
      new('OpenGovManager', Manager)
    end

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

    def init_ar(db)
      conf = YAML::load(File.open(Config::RootDir + '/db/config.yml'))[db]
      ActiveRecord::Base.establish_connection(conf[Config::Environment])
    end
  end
end
