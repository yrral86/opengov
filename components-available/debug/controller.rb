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

  def people
    type = 'Person'
    objects = []
    @client.cm.components_with_type(type).each do |component|
      if model = @client.get_component(component).model_by_type(type)
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
