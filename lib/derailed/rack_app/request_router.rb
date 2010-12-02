module Derailed
  module RackApp
    # = Derailed::RackApp::RequestRouter
    # This class is a Rack application that takes incoming requests and routes
    # them to the appropriate component.
    class RequestRouter
      # initialize creates a Client to access the components and the
      # Manager, initializes an empty hash for routing paths to components,
      # and starts the DRb service that allows the components to access the
      # session and cookie hashes in the Derailed::RackApp::Controller
      def initialize
        @manager = Service.get('Manager')
        @proxies = {}
        @logger = Logger.new 'RequestRouter'
        Service.start
        self
      end

      # call handles the incoming request.  First, if we have no proxies,
      # we ask the Manager for them via update_proxies.
      # We then choose the proxy via the first part of the path.
      # If we have a component to handle that path, we attempt to invoke its
      # call method, otherwise we return a 404 Not found.  If the invocation of
      # call on the component throws an error, we empty the routes hash (so the
      # new list of routes are fetched on the next request... we assume an error
      # means there was an error connecting to the component). We then return
      # a 500.
      def call(env)
        update_proxies if @proxies.empty?

        path = env[:controller].next
        if @proxies[path] == nil
          Component::View.not_found 'Not Found'
        else
          begin
            @proxies[path].call(env)
          rescue => e
            @logger.debug e
            @logger.backtrace e.backtrace
            @proxies = {}
            Component::View.internal_error("Error in component #{path}")
          end
        end
      end

      private
      # updates the proxies hash
      def update_proxies
        @proxies = {}

        # grab routes from manager (DRb)
        routes = {}
        begin
          routes = @manager.available_routes
        rescue => e
          @logger.backtrace e.backtrace
        end

        routes.each_key do |path|
          # grab a proxy object for the route
          begin
            @proxies[path] = Proxy.fetch(routes[path])
          rescue
            @logger.backtrace e.backtrace
          end
        end
      end
    end
  end
end
