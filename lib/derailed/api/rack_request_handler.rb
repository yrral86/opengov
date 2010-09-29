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
      # request_response(env) -> uri, key
      # key is then passed to fetch_response
      def request_response; end
    end
  end
end
