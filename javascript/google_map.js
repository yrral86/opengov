var google_map = {
    geocoder: new google.maps.Geocoder(),
    addresses: new Hash(),
    markers: new Hash(),
    init: function() {
        options = {
	    center: google.maps.LatLng(40,-81),
	    zoom: 8,
	    mapTypeId: google.maps.MapTypeId.ROADMAP
        };
        google_map.map = new google.maps.Map($('map'),options);
    },
    map_addresses: function() {
	google_map.clear_markers();
	google_map.addresses.each(function(pair) {
		google_map.current_id = pair.key;
		var request = {address: pair.value};
		google_map.geocoder.geocode(request, google_map.map_address);
	    });
	///FIXME: hackish, and only works when geocoding one address
	// multiple simultaneous requests result in current_id being stomped on
	setTimeout(google_map.set_bounds, 1000);
    },
    set_bounds: function() {
	var bounds = new google.maps.LatLngBounds();
	google_map.markers.each(function(pair) {
		bounds.extend(pair.value.getPosition());
	    });
	google_map.map.fitBounds(bounds)
    },
    map_address: function(result, status) {
        var options = {
	    position: result[0].geometry.location,
	    title: result[0].formatted_address
        };
	google_map.new_marker(google_map.current_id, options);
    },
    new_marker: function(id, options) {
	options.map = google_map.map;
        var marker = new google.maps.Marker(options);
	google_map.markers.set(id, marker);
    },
    clear_markers: function () {
	google_map.markers.each(function(pair) {
		pair.value.setMap(null);
	    });
	google_map.markers = new Hash();
    },
    add_address: function(id, address) {
        google_map.addresses.set(id, address);
	google_map.map_addresses();
    },
    remove_address: function(id) {
	google_map.addresses.unset(id);
	google_map.map_addresses();
    }
}