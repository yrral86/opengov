require 'derailed/poller'

class MapController < Derailed::Component::Controller
  include MapHelpers

  def initialize(component, manager)
    super(component, manager)
    @map_poller = Derailed::Poller.new
  end

  def address_lookup
    q = params['q']
    objects = Location.limit(5).where("title LIKE ?", "%#{q}%")
    render 'addresses', binding
  end

  def index
    user = @component.current_user
    map = Map.from_user user.id
    @map_poller.reset_user user.id
    locations_updated user.id
    render 'map', binding
  end

  def location
    delete_override do |id|
      user = @component.current_user
      map = Map.from_user user.id
      map.remove_location id
      locations_updated user.id
      render_string "Location ##{id} Deleted"
    end
  end

  def locations
    user = @component.current_user
    @map_poller.render(user.id) do
      map = Map.from_user user.id
      objects = map.locations
      load_locations = locations_js(map.locations)
      render 'locations', binding
    end
  end

  def update_locations
    id = params['id'] || @component.current_user.id
    locations_updated(id)
    render_string "marked locations for update"
  end

  def update_address
    attribs = params.dup
    attribs.delete('_ajax');
    user = @component.current_user
    map = Map.from_user user.id
    map.add_location attribs
    locations_updated user.id
    render_string ''
  end

  def location_share
    id = path 3
    location = Location.find id
    render 'location_share', binding
  end

  def location_add
    id = path 3
    current_map.locations << Location.find(id)
    locations_updated @component.current_user.id
    render_string ''
  end

  def share
    location = Location.find params['location_id']
    params['user_id'].each do |id|
      location.share_with id
      locations_updated id
    end
    render_string "Location #{location.title} shared"
  end

  private
  def locations_updated(user_id)
    @map_poller.renderable(user_id)
  end

  def current_map
    Map.from_user @component.current_user.id
  end
end
