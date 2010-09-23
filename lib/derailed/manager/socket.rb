module Derailed
  module Manager
    # = Derailed::Manager::Socket
    # This class provides socket uri's based on the selected environment
    class Socket
      # self.read_config reads the configuration file to determine the socket
      # directory
      def self.read_config
        @@dir = Config.socket_dir
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
