module Derailed
  module API
    ##
    # Feature: Base API
    #   As a component developer
    #   In order to find out what an object can do
    #   I want to ask the allowed methods of the object
    #   And ask if the object allows a particular method
    #   And ask the allowed apis of the object
    #   And ask the name of the object
    #   And ask the uri of the server
    #
    #   Background:
    #     Given I am testing API::Base
    ##
    module Base
      ##
      # Scenario Outline: ask if the object allows a particular method
      #   Given the object implements <API>
      #   And <requester> is trying to acces it
      #   When I call object.respond_to?(<allowed_method>)
      #   Then the object should not throw InvalidAPI
      #   When I call object.respond_to?(<restricted_method>)
      #   Then the object should throw InvalidAPI
      #
      #   Scenarios:
      #     | API     | requester     | allowed_method     | restricted_method |
      #     | Base    | RackApp       | respond_to?(:apis) | denied?           |
      #     | Base    | Manager       | respond_to?(:no_m) | eval('evil hax')  |
      #     | Manager | Static        | available_types    | crazy_method      |
      #     | Manager | Authenticator | current_session    | previous_session  |
      #     | Base    | Map           | allowed?(:denied?) | eval('evil hax')  |
      ##
      def respond_to?; end

      ##
      # Scenario Outline: ask the allowed methods of the object
      #   Given the object implements <API>
      #   When I call object.allowed_methods
      #   Then the result should include [<methods>]
      #
      #   Scenarios:
      #     | API      | methods                                              |
      #     | Base     | apis,name,allowed_methods,allowed?                   |
      #     | Manager  | available_components,available_models                |
      #     | Manager  | available_routes,available_types,componenent_pid     |
      #     | Manager  | components_with_type,component_command,check_key     |
      #     | Manager  | register_component,unregister_component              |
      ##
      def allowed_methods; end

      ##
      # Scenario Outline: ask the allowed apis of the object
      #   Given the object implements <API>
      #   And I figure out a way to make sure this actually exercises the api
      #   When I call object.apis
      #   Then the result should include [<API>]
      ##
      def apis; end



      ##
      # Scenario Outline: ask the name of the object
      #
      ##
      def name; end

      ##
      # Scenario Outline: ask the uri of the server
      ##
      def uri; end
    end
  end
end
