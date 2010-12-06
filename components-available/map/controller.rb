require 'derailed/poller'

class MapController < Derailed::Component::Controller
  def initialize(component, manager)
    super(component, manager)
    @location_poller = Derailed::Poller.new
  end

  def index
    user = @component.current_user
    map = Map.find_or_create_by_user_id user[:id]
    render 'map', binding
  end

  def locations
    user = @component.current_user
    @location_poller.render(user.id) do
      map = Map.find_or_create_by_user_id user[:id]
      objects = map.locations
      render 'locations', binding
    end
  end

  def update_locations
    locations_updated(@component.current_user.id)
    render_string "marked locations for update"
  end

  private
  def locations_updated(user_id)
    @location_poller.renderable(user_id)
  end
end
