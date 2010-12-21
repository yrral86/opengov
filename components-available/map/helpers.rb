module MapHelpers
  private
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
