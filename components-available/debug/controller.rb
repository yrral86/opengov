class DebugController < Derailed::Component::Controller
  def test
    render_string "DebugController says hi!"
  end

  def info
    available_models = @client.cm.available_models
    available_components = @client.cm.available_components
    available_types = @client.cm.available_types
    routes = @client.cm.available_routes
    available_routes = []
    routes.each_pair do |k,v|
      available_routes << "/#{k} => #{v.name}"
    end
    render 'info', binding
  end
end
