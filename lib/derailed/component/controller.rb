module Derailed
  module Component
    # = Derailed::Component::Controller
    # This class provides a mechanism to customize the request handling process
    # of a component.  Methods defined in a subclass of this class will be
    # called when a request for the path matching the function name comes in.
    # ==== example:
    # component = PersonLocator
    # request path = /personlocator/example
    #
    # Component will call controller.example, and if it is not defined,
    # we will return a 404
    class Controller
      def method_missing(id, *args)
        View.not_found "Method not found: #{id}"
      end
    end
  end
end
