module Derailed
  module API
    ##
    # Feature: RackComponent API
    #   As a component developer
    #   In order to allow Manager to aggregate routes for the RackApp
    #   I want to allow querying the routes
    ##
    module RackComponent
      include RackRequestHandler
      include RackRequestResponder
      private
      ##
      # Scenario: allow querying the routes
      ##
      def routes; end
    end
  end
end

