require 'drb'
require 'drb/timeridconv'

module Derailed
  module Service
    def self.start(uri = nil, object = nil)
      DRb.install_id_conv DRb::TimerIdConv.new(Config::DRbTimeout)
      DRb.start_service uri, object
    end
  end
end
