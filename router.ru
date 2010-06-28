require 'drb'
require 'lib/componenthelper'

class OpenGovRequestRouter
  def initialize
    @ch = OpenGovComponentHelper.new
    @routes = {}
    @r_mutex = Mutex.new

    DRb.start_service 'drbunix://tmp/opengovrequestrouter.sock', self
    at_exit {
      DRb.stop_service
    }
    self
  end

  def register_component(component)
    name = component.name
    new_routes = {}
    @r_mutex.synchronize do
      component.routes.each do |r|
        if @routes[r] == nil then
          new_routes[r] = @ch.get_component(name)
        else
          raise "Route '" + r + "' already handled by component " + @routes[r].name
        end    
      end
      @routes.update(new_routes)
    end
  end

  def unregister_component(component)
    @r_mutex.synchronize do
      component.routes.each do |r|
        @routes.delete(r)
      end
    end
  end

  def call(env)
    req = Rack::Request.new(env)

    path = req.path.split "/"

    if @routes[path[1]] == nil then
      [404, {'Content-Type' => 'text/html'}, ['Not Found']]
    else
      @routes[path[1]].call(env)
    end
  end  
end

app = OpenGovRequestRouter.new()
run app
