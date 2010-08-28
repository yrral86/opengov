require 'yaml'

dir = File.expand_path(File.dirname(__FILE__))

require dir + '/../config'

module Derailed
  module Manager
    # = Derailed::Manager::Socket
    # This class provides socket uri's based on the selected environment
    class Socket
      # self.read_config reads the configuration file to determine the socket
      # directory
      def self.read_config
        config_file = "#{Config::RootDir}/config/environments.yml"
        config = YAML::load(File.open(config_file))[Config::Environment]
        @@dir = config['socket_dir']
        @@dir = "#{Config::RootDir}/#{@@dir}" if @@dir[0] == '.'
      end

      # self.uri returns the socket uri for a given name
      def self.uri(name)
        "drbunix:#{@@dir}/#{name}.sock"
      end

      # self.dir returns the socket directory
      def self.dir
        @@dir
      end
    end
  end
end

Derailed::Manager::Socket.read_config
