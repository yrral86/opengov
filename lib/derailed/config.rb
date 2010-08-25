module Derailed
  module Config
    RootDir = File.expand_path(File.dirname(__FILE__)) + '/../../'
    Environment = ENV['ENV'] || 'development'
  end
end
