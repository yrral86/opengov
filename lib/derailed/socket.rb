require 'yaml'

module Derailed
  # = Derailed::Socket
  # This class provides socket uri's based on the selected environment
  class Socket
    # self.read_config reads the configuration file to determine the socket
    # directory
    def self.read_config
      @@dir = YAML::load(File.open("#{Config::RootDir}/config/environments.yml"))[Config::Environment]['socket_dir']
      @@dir = "#{File.expand_path(File.dirname(__FILE__))}/../../#{@@dir}" if @@dir[0] == '.'
    end

    # self.get_socket_uri returns the socket uri for a given name
    def self.get_socket_uri(name)
      "drbunix:#{@@dir}/#{name}.sock"
    end

    # self.dir returns the socket directory
    def self.dir
      @@dir
    end
  end
end

Derailed::Socket.read_config
