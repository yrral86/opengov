require 'yaml'

module Derailed
  # = Derailed::Config
  # This module provides global configuration information
  module Config
    RootDir = File.expand_path(File.dirname(__FILE__) + '/../..')
    ControlScript = RootDir + '/control.rb'
    ComponentDir = RootDir + '/components-enabled'
    LibDir = RootDir + '/lib'
    Environment = ENV['ENV'] || 'development'
    MaxComponentStart = 2
    # RequestTimeout < SessionTimeout < DRbTimeout
    RequestTimeout = 40
    SessionTimeout = 2*RequestTimeout
    # PreviousSessionTimeout has to be long enough that all request made
    # simultaneously will be  handled.  This only matters when the session
    # is not cached and multiple requests come in at the same time.  And even
    # then it won't be hit very often, only when the instructions are woven
    # just right (or wrong ;)... Increasing this value keeps old sessions valid
    # for that much longer, decreasing it below the time it takes to service
    # all simultaneous requests from the same user leaves you open to an
    # authentication failure for one or more of those requests.
    PreviousSessionTimeout = 5
    DRbTimeout = 2*SessionTimeout
    LoggerShiftAge = 0 # default
    LoggerShiftSize = 1048576 # default

    # component_config reads the config file and sets some defaults
    def self.component_config(component)
      config = YAML::load(File.open("#{ComponentDir}/#{component}/config.yml"))
      config['apis'] ||= []
      config['requirements'] ||= []
      config['db'] ||= 'default'
      config['class'] ||= 'Base'
      config
    end

    def self.db_config(db)
      config = YAML::load(File.open("#{RootDir}/db/config.yml"))[db]
      config[Environment]
    end

    def self.tmp_dir
      config_file = "#{RootDir}/config/environments.yml"
      @@env_config ||= YAML::load(File.open(config_file))[Environment]
      dir = @@env_config['tmp_dir']
      dir = "#{RootDir}/#{dir}" if dir.match('^\.')
      dir
    end

    def self.socket_dir
      tmp_dir
    end

    def self.log_dir
      tmp_dir
    end

    def self.pid_dir
      tmp_dir
    end
  end
end
