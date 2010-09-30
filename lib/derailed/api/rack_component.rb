module Derailed
  module API
    ##
    # Feature: RackComponent API
    #   As a component developer
    #   In order to handle HTTP requests
    #   I want to implement Rack's call specification
    #   And allow the Manager to query the routes
    ##
    module RackComponent
      ##
      # Scenario: implement Rack's call specification
      ##
      def call; end

      private
      ##
      # Scenario: allow the Manager to query the routes
      ##
      def routes; end
    end
  end
end

