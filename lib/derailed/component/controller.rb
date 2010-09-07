dir = File.expand_path(File.dirname(__FILE__))
[
 'crud',
 'environment',
 'helpers',
 'view'
].each do |library|
  require "#{dir}/#{library}"
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

      def initialize(component)
        @component = component
        @safe_names = whitelist
      end

      private
      def allowed(name)
        @safe_names.include?(name)
      end

      def method_missing(id, *args)
        if allowed(id.to_s)
          crud(Thread.current[:env])
        else
          not_found "Method #{id.to_s} not found in component " +
            @component.name
        end
      end

      def whitelist
        array = self.public_methods - Object.new.public_methods
        array += @component.model_names
        array.map {|m| m.to_s}
      end
    end
  end
end
