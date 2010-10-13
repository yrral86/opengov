class DebugController < Derailed::Component::Controller
  def test
    logger.debug "debug: Hello from DebugController"
    logger.info "information: Hello from DebugController"
    logger.warn "warning: Hello from DebugController"
    render_string "DebugController says hi!"
  end

  def raise
    raise
  end

  def info
    available_models = @manager.available_models
    available_components = @manager.available_components
    available_types = @manager.available_types
    routes = @manager.available_routes
    available_routes = []
    routes.each_pair do |k,v|
      available_routes << "/#{k} => #{v}"
    end
    render 'info', binding
  end

  def people
    type = 'Person'
    objects = []
    @manager.components_with_type(type).each do |component|
      if model = Derailed::Service.get(component).model_by_type(type)
        objects.concat(model.find(:all))
      else
        throw ThisShouldNotBePossible
        # If the component does not have a model with the specified type
        # then components_with_type lied to us
      end
    end
    objects.map! {|record| Derailed::Type::Person.new(record)}
    render 'people', binding
  end
end
