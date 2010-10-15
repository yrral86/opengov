module Derailed
  module API
    ##
    # Feature: Session API
    #   As a component developer
    #   In order to be confident in the authorization of an information request
    #   I can request the current session from the Authenticator
    #
    #   Background:
    #     Given I am testing 'API::Session'
    ##
    module Session
      ##
      # Scenario: request the current session from the Authenticator
      #   Given the object implements 'Session'
      #   When I call object.allowed_methods
      #   Then the results should include [current_session]
      ##
      def current_session; end
    end
  end
end
