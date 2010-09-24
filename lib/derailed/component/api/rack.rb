module Derailed
  module Component
    module API
      ##
      # Feature: Rack API
      #   As a component developer
      #   In order to allow the component to act as a Rack application
      #   I want to allow access to the call method of the component
      ##
      module Rack
        ##
        # Scenario: allow access to the call method of a component
        ##
        def call; end
      end
    end
  end
end