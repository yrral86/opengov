module Derailed
  class Socket
    def self.read_config
      @@dir = YAML::load(File.open("#{Config::RootDir}/config/environments.yml"))[Config::Environment]['socket_dir']
    end

    def self.get_socket_uri(name)
      "#{@@dir}/#{name}.sock"
    end
  end
end

Derailed::Socket.read_config
