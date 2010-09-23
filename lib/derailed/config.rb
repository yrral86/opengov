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
  end
end
