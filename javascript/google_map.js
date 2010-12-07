var google_map = {
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
		google_map.new_marker(pair.key, pair.value);
	    });
	google_map.set_bounds();
    },
    set_bounds: function() {
	var bounds = new google.maps.LatLngBounds();
	google_map.markers.each(function(pair) {
		bounds.extend(pair.value.getPosition());
	    });
	google_map.map.fitBounds(bounds)
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
    add_address: function(id, lat, lng, title) {
	var value = {
	    position: new google.maps.LatLng(lat, lng),
	    title: title
	};
        google_map.addresses.set(id, value);
    },
    remove_address: function(id) {
	google_map.addresses.unset(id);
	google_map.map_addresses();
    }
}