require 'lib/componenthelper'

class OpenGovRequestRouter
  def initialize
    @ch = OpenGovComponentHelper.new
    @routes = {}
    DRb.start_service
    self
  end

  def call(env)
    @routes = @ch.get_routes if @routes.empty?

    r = Rack::Request.new(env)

    path = r.path.split "/"

    if @routes[path[1]] == nil then
      [404, {'Content-Type' => 'text/html'}, ['Not Found']]
    else
      @routes[path[1]].call(env)
    end
  end
end
