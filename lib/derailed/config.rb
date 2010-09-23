module Derailed
  # = Derailed::Config
  # This module provides global configuration information
  module Config
    RootDir = File.expand_path(File.dirname(__FILE__) + '/../..')
    ComponentDir = RootDir + '/components-enabled'
    Environment = ENV['ENV'] || 'development'

    # component_config reads the config file and sets some defaults
    def self.component_config(component)
      config = YAML::load(File.open("#{ComponentDir}/#{component}/config.yml"))
      config['requirements'] ||= []
      config['db'] ||= 'default'
      config['class'] ||= 'Base'
      config
    end

    def self.db_config(db)
      config = YAML::load(File.open("#{RootDir}/db/config.yml"))[db]
      config[Environment]
    end

    def self.socket_dir
      config_file = "#{RootDir}/config/environments.yml"
      config = YAML::load(File.open(config_file))[Environment]
      dir = config['socket_dir']
      dir = "#{RootDir}/#{@@dir}" if @@dir.match('^\.')
      dir
    end
  end
end
