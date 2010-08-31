require 'daemons'

module Derailed
  class Daemon
    Component = 0
    Manager = 1

    def initialize(name, type=Component)
      @name = name
      @type = type
    end

    def self.component(name)
      new(name)
    end

    def self.manager
      new('OpenGovManager', Manager)
    end

    def daemonize
      name = @type == Component ? "OpenGov#{@name}Component" : @name
      Daemons.run_proc(name, {:dir_mode => :normal, :dir => Config::RootDir}) do
        yield
      end
    end
  end
end
