require 'drb'
require 'drb/timeridconv'

require 'derailed/proxy'
require 'derailed/socket'
require 'derailed/util'

module Derailed
  # This module provides methods to start and stop a DRb server, as well
  # as to get a proxy object to access a DRb server started with Service.start
  module Service
    # self.start starts a DRb server of the given name for the given object.
    # If name and object are not specified, we will still start a server.
    # This is to allow bidirectional communication, particularly for the
    # components to access the RackApp-side controller
    def self.start(name = nil, object = nil)
      uri = name ? Socket.uri(name) : nil
      DRb.install_id_conv DRb::TimerIdConv.new(Config::DRbTimeout)
      DRb.start_service uri, object
      uri
    end

    # self.join joins the DRb server's thread with the current thread
    def self.join
      DRb.thread.join
    end

    # self.stop stops the DRb server
    def self.stop
      DRb.stop_service
    end

    # self.get creates a proxy object for the service specified
    def self.get(name)
      Proxy.fetch(Socket.uri name)
    end

    def self.get_model(name)
      server, model = name.split '::'
      Service.get(server).model(model)
    end

    def self.get_logger
      Service.get('Manager').logger
    end
  end
end
