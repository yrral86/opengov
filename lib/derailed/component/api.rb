module Derailed
  module Component
    ##
    # Feature: Provide a locked down interface to the component
    #   As a component developer
    #   I want to ensure my components are secure
    ##
    class API
      def initialize(component)
        @component = component
        @safe_names = whitelist
      end

      private
      def allowed?(name)
        @safe_names.include?(name)
      end

      def method_missing(id, *args)
        if allowed?(id.to_s)
          @component.send id, args
        else
          super
        end
      end

      def whitelist
        array = self.public_methods - Object.new.public_methods
        array.map {|m| m.to_s}
      end
    end
  end
end