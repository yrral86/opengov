require 'yaml'

module Derailed
  class Socket
    def self.read_config
      @@dir = YAML::load(File.open("#{Config::RootDir}/config/environments.yml"))[Config::Environment]['socket_dir']
      @@dir = "#{File.expand_path(File.dirname(__FILE__))}/../../#{@@dir}" if @@dir[0] == '.'
    end

    def self.get_socket_uri(name)
      "drbunix:#{@@dir}/#{name}.sock"
    end

    def self.dir
      @@dir
    end
  end
end

Derailed::Socket.read_config
