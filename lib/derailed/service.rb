require 'drb'
require 'drb/timeridconv'

require 'derailed/socket'

module Derailed
  module Service
    def self.start(name = nil, object = nil)
      uri = name ? Socket.uri(name) : nil
      DRb.install_id_conv DRb::TimerIdConv.new(Config::DRbTimeout)
      DRb.start_service uri, object
    end

    def self.get(name)
      DRbObject.new nil, Socket.uri(name)
    end
  end
end
