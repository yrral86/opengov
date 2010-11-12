require 'yaml'

module Derailed
  # = Derailed::Config
  # This module provides global configuration information
  module Config
    RootDir = File.expand_path(File.dirname(__FILE__) + '/../..')
    ComponentDir = RootDir + '/components-enabled'
    LibDir = RootDir + '/lib'
    Environment = ENV['ENV'] || 'development'
    PollTimeout = 10
    SessionTimeout = 2*PollTimeout
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
