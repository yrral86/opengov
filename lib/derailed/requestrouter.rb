dir = File.expand_path(File.dirname(__FILE__))

module Derailed
  # = Deraild::RequestRouter
  # This class is a Rack application that takes incoming requests and routes
  # them to the appropriate component.
  class RequestRouter
    # initialize creates a ComponentClient to access the components and the
    # Manager, initializes an empty hash for routing paths to components,
    # and starts the DRb service that allows the components to access the
    # session and cookie hashes in the Derailed::Controller::Controller
    def initialize
      @cc = ComponentClient.new
      @routes = {}
      DRb.start_service
      self
    end

    # call handles the incoming request.  First, if we have no routes,
    # we ask the Manager for them via ComponentClient.get_routes.
    # We then choose the component via the first part of the path.
    # If we have a component to handle that path, we attempt to invoke its call
    # method, otherwise we return a 404 Not found.  If the invocation of call
    # on the component throws an error, we empty the routes hash (so the new
    # list of routes are fetched on the next request... obviously at least one
    # of the routes we had was invalid). We then return a 404.
    def call(env)
      @routes = @cc.get_routes if @routes.empty?

      component = env[:controller].next
      if @routes[component] == nil then
        Component::View.not_found 'Not Found'
      else
        begin
          @routes[component].call(env)
        rescue DRb::DRbConnError
          @routes = {}
          Component::View.not_found "Component #{component} went away"
        end
      end
    end
  end
end
