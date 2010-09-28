module Derailed
  module API
    ##
    # Feature: Rack API
    #   As a component developer
    #   In order to allow the component to act as a Rack application
    #   I want to allow access to the call method of the component
    #   And allow querying the routes
    ##
    module Rack
      ##
      # Scenario: allow access to the call method of the component
      ##
      def call; end

      private
      ##
      # Scenario: allow querying the routes
      ##
      def routes; end
    end
  end
end

