[
 'crud',
 'environment',
 'helpers',
 'view'
].each do |library|
  require "derailed/component/#{library}"
end

module Derailed
  module Component
    # = Derailed::Component::Controller
    # This class provides a mechanism to customize the request handling process
    # of a component.  Methods defined in a subclass of this class will be
    # called when a request for the path matching the function name comes in.
    # ==== example:
    #  component = PersonLocator
    #  request path = /personlocator/example
    #
    #  Component will call controller.example, and if it is not defined,
    #  we will return a 404
    class Controller
      include Crud
      include Environment
      include Helpers
      include View

      # initialize sets the component and component client and generates a
      # whitelist of method names that can be called as URLs
      def initialize(component, client)
        @component = component
        @client = client
        @safe_names = whitelist
      end

      # index defaults to saying hi
      def index
        render_string "Hello, from the #{@component.name} controller"
      end

      private
      # allowed determines if the given name is on the whitelist
      def allowed(name)
        @safe_names.include?(name)
      end

      # method_missing checks if the function name is allowed and if it is
      # (and it's not defined, as we're in method_missing), it is a model, so
      # we call crud.  Otherwise, it returns a 404.
      def method_missing(id, *args)
        if allowed(id.to_s)
          crud(Thread.current[:env])
        else
          not_found "Method #{id.to_s} not found in component " +
            @component.name
        end
      end

      # whitelist generates a list of methods that can be called as URLs
      def whitelist
        array = self.public_methods - Object.new.public_methods
        array += @component.model_names.map {|n| n.downcase}
        array.map {|m| m.to_s}
      end
    end
  end
end
