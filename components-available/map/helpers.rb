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

  def available_officers
    officers = @component.all_officers
    officers.delete @component.current_user
    officers.collect do |o|
      if o
        <<eof
<input type="checkbox" name="user_id[]" value="#{o.id}"/> #{o.username}
eof
      end
    end.join '<br />'
  end
end
