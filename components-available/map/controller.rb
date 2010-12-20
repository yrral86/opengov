require 'derailed/poller'

class MapController < Derailed::Component::Controller
  def initialize(component, manager)
    super(component, manager)
    @location_poller = Derailed::Poller.new
  end

  def index
    user = @component.current_user
    map = Map.find_or_create_by_user_id user.id
    @location_poller.reset_user user.id
    locations_updated user.id
    render 'map', binding
  end

  def location
    if (request.post? && params['_method'] == 'delete') ||
        request.delete?
      id = path 3
      user = @component.current_user
      map = Map.find_or_create_by_user_id user.id
      locations = MapLocation.find(:all, :conditions => {:location_id => id,
                                     :map_id => map.id})
      locations.each do |location|
        location.delete if user.id == location.map.user_id
      end
      locations_updated user.id
      render_string "Location ##{id} Deleted"
    else
      method_missing(:location)
    end
  end

  def locations
    user = @component.current_user
    @location_poller.render(user.id) do
      map = Map.find_or_create_by_user_id user.id
      objects = map.locations
      load_locations = locations_js(map.locations)
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
    location = Location.find_or_create_by_title attribs['title']
    # if we have an address, the address is in the title, so we can assume
    # this is the same
    if location.address
      update_location_and_map location, attribs, map
    # if we don't have an address, the title could represent a rural route,
    # so this might not be the same.
    elsif location.latitude
      map.locations.create attribs
    # Also, it might be new
    else
      update_location_and_map location, attribs, map
    end
    locations_updated user.id
    render_string ''
  end

  private
  def update_location_and_map(location, attribs, map)
    begin
      location.update_attributes attribs
    rescue => e
      $stderr.puts e.inspect
    end
    location.maps << map
  end

  def locations_updated(user_id)
    @location_poller.renderable(user_id)
  end

  def locations_js(locations)
    load = 'google_map.clear_addresses();'
    locations.each do |l|
      load +=
        "google_map.add_address(#{l.id}, '#{l.latitude}', '#{l.longitude}'," +
        "'#{l.title}');"
    end
    load += "google_map.map_addresses();"
    load
  end
end
