module Derailed
  module API
    ##
    # Feature: RackRequest API
    #   As a RackApp instance
    #   In order to pass requests to a Manager
    #   I have to encapsulate env in an API
    ##
    module RackRequest
      # env -> standard Rack env variable
      # RackApp wraps env in this type to pass to Manager
      def env; end
    end
  end
end
