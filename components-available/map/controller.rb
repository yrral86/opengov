require 'derailed/poller'

class MapController < Derailed::Component::Controller
  def initialize(component, manager)
    super(component, manager)
    @location_poller = Derailed::Poller.new
  end

  def index
    user = @component.current_user
    map = Map.find_or_create_by_user_id user.id
    load_locations = ''
    map.locations.each do |l|
      load_locations +=
        "google_map.add_address(#{l.id}, '#{l.formatted_address || l.coords}');"
    end
    render 'map', binding
  end

  def locations
    user = @component.current_user
    @location_poller.render(user.id) do
      map = Map.find_or_create_by_user_id user.id
      objects = map.locations
      render 'locations', binding
    end
  end

  def update_locations
    locations_updated(@component.current_user.id)
    render_string "marked locations for update"
  end

  def update_address
    attribs = params.dup
    attribs.delete('_ajax');
    user = @component.current_user
    map = Map.find_or_create_by_user_id user.id
    map.locations.create attribs
    locations_updated user.id
    render_string ''
  end

  private
  def locations_updated(user_id)
    @location_poller.renderable(user_id)
  end
end
