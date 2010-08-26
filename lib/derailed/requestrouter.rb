dir = File.expand_path(File.dirname(__FILE__))

module Derailed
  class RequestRouter
    def initialize
      @ch = ComponentHelper.new
      @routes = {}
      DRb.start_service
      self
    end

    def call(env)
      @routes = @ch.get_routes if @routes.empty?

      component = env[:controller].next
      if @routes[component] == nil then
        View.not_found 'Not Found'
      else
        begin
          @routes[component].call(env)
        rescue DRb::DRbConnError
          @routes = {}
          View.not_found "Component #{component} went away"
        end
      end
    end
  end
end
