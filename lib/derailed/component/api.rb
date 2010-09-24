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
        @@apis = []
        extensions.each do |e|
          register_api(e,true)
        end
        @@extended_names = gen_whitelist
        self
      end

      ##
      # Scenario: list methods the component allows
      #   Given '<component>' is running
      #   And '<component>' has '<APIs>'
      #   When I call 'allowed_methods' on the DRbObject for '<component>'
      #   Then the return value should contain all of the methods in '<APIs>'
      ##
      def allowed_methods
        @@extended_names
      end
      module_function :allowed_methods
      public :allowed_methods

      ##
      # Scenario: list APIs the component implements
      #   Given '<component>' is running
      #   And '<component>' has '<APIs>'
      #   When I call 'apis' on the DRbObject for '<component>'
      #   Then the return value should contain '<APIs>'
      ##
      def apis
        @@apis
      end
      module_function :apis
      public :apis

      def name
        @@component.name
      end
      module_function :name
      public :name

      def allowed?(name)
        @@extended_names.include? name
      end
      module_function :allowed?
      public :allowed?

      private

      def self.register_api(api, no_gen = false)
        unless caller[0].match /drb\.rb/
          self.send :include, api
          @@extended_names = gen_whitelist unless no_gen
          @@apis << api.name
        else
          throw InvalidAPI
        end
      end

      ##
      # Scenario: limit the API that can be called over the wire
      #   Given '<component>' is running
      #   And '<component>' has '<APIs>'
      #   When I call 'allowed_methods' on the DRbObject for '<component>'
      #   And I call each returned value on the DRbObject for '<component>'
      #   Then calling anything not returned should throw an error
      ##
      def self.method_missing(id, *args)
        if allowed?(id)
            @@component.send id, *args
        else
          throw InvalidAPI
        end
      end

      def self.gen_whitelist
        array = self.public_instance_methods
        array.map {|m| m.to_s}
        array
      end

      [
       'Authenticator',
       'Base',
       'Models',
       'Testing',
       'Rack'
      ].each do |library|
        autoload library.to_sym, "derailed/component/api/#{library.downcase}"
      end
    end
  end
end
