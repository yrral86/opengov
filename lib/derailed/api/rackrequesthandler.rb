module Derailed
  module API
    ##
    # Feature: RackRequestHandler API
    #   As a Manager instance
    #   In order to handle a RackRequest
    #   I want to authenticate the request
    #   And generate a :request_key
    #   And pass the key and request to the component
    ##
    module RackRequestHandler
      # intiate_request(RackRequest) -> RequestKey
      # RequestKey is passed by RackApp to request_response, which returns
      # the response in standard Rack array format
      def initiate_request; end
    end
  end
end
