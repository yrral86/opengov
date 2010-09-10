module Derailed
  # = Derailed::Config
  # This module provides global configuration information
  module Config
    RootDir = File.expand_path(File.dirname(__FILE__) + '/../..')
    ComponentDir = RootDir + '/components-enabled'
    Environment = ENV['ENV'] || 'development'
  end
end
