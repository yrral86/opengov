dir = File.expand_path(File.dirname(__FILE__))
require dir + '/crud'
require dir + '/environment'
require dir + '/view'

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
      include View

      def initialize(component)
        @component = component
        @safe_names = whitelist
      end

      def allowed(name)
        @safe_names.include?(name)
      end

      private
      def method_missing(id, *args)
        crud(Thread.current[:env])
      end

      def whitelist
        array = self.public_methods - Object.new.public_methods
        array -= ['allowed']
        array += @component.model_names
        array.map {|m| m.to_s}
      end
    end
  end
end
