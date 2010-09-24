[
 'rack'
].each do |library|
  require "derailed/component/api/#{library}"
end

module Derailed
  module Component
    class InvalidAPI < ::StandardError
      def initialize(session)
        super("The api you used is invalid")
      end
    end

    ##
    # Feature: Locked down interface for a component
    #   As a component developer
    #   In order to secure the component
    #   I want to limit the API that can be called over the wire
    #   And list methods the component allows
    #   And list APIs the component implements
    ##
    module API
      def self.new(component, extensions=[])
        @@component = component
        @@apis = extensions
        @@safe_names = whitelist
      end

      ##
      # Scenario: list methods the component allows
      #   Given '<component>' is running
      #   And '<component>' has '<APIs>'
      #   When I call 'allowed_methods' on the DRbObject for '<component>'
      #   Then the return value should contain all of the methods in '<APIs>'
      ##
      def self.allowed_methods
        @@safe_names
      end

      ##
      # Scenario: list APIs the component implements
      #   Given '<component>' is running
      #   And '<component>' has '<APIs>'
      #   When I call 'apis' on the DRbObject for '<component>'
      #   Then the return value should contain '<APIs>'
      ##
      def self.apis
        @@apis
      end

      private
      def self.allowed?(name)
        @@safe_names.include?(name)
      end

      def self.method_missing(id, *args)
        if allowed?(id.to_s)
          @@component.send id, args
        else
          throw InvalidAPI
        end
      end

      def self.whitelist
        array = self.public_methods - Object.new.public_methods
        array.map {|m| m.to_s}
      end
    end
  end
end
