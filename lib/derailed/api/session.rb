module Derailed
  module API
    ##
    # Feature: Session API
    #   As a component developer
    #   In order to be confident in the authorization of an information request
    #   The manager can fetch the current_session
    #   And verify that the Sesson has access to the resouce
    #
    #   Background:
    #     Given I am testing API::Session
    ##
    module Session
      ##
      # Scenario: the manager implements Session
      #   Given the object proxies 'Manager'
      #   When I call object.apis
      #   Then the results should include [verify_session]
      ##
      def current_session; end

      ##
      # Scenario Outline: verify that the Session has access to the resouce
      #   Given the object implements Session
      #   And object has access to <resouce>
      #   When I call object.verify_session
      #   Then the result is true
      ##
      def verify_session; end
    end
  end
end
