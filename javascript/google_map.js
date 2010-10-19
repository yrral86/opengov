var google_map = {
    geocode: new google.maps.Geocoder().geocode,
    addresses: ['424 Evans Street, Morgantown, WV 26505','RR 1 Box 102, Glen Easton, WV 26039'],
    markers: [],
    address_count: 2,
    current_address: 0,
    init: function() {
        options = {
	    center: google.maps.LatLng(80,70),
	    zoom: 8,
	    mapTypeId: google.maps.MapTypeId.ROADMAP
        };
        this.map = new google.maps.Map($('map'),options);
        this.map_addresses();
    },
    map_addresses: function () {
        if (this.current_address == 0) {
	    this.clear_markers();
        }
        if (this.current_address < this.address_count) {
	    request = {address: this.addresses[this.current_address++]};
	    this.geocode(request, this.map_address);
	} else {
	    this.current_address = 0;
	}
    },
    map_address: function(result, status) {
        var options = {
	    position: result[0].geometry.location,
	    title: result[0].formatted_address
        };
	google_map.new_marker(options);
    },
    new_marker: function(options) {
	this.map.setCenter(options.position);
	options.map = this.map;
        var marker = new google.maps.Marker(options);
	this.markers[this.current_address - 1] = marker;
        this.map_addresses();
    },
    clear_markers: function () {
	for (var i = 0; i < this.address_count; i++) {
	    var marker = this.markers[i];
	    if (marker) {
		marker.setMap(null);
	    }
	}
    },
    add_address: function () {
        this.addresses[this.address_count++] = $('add_address').address.value;
        this.map_addresses();
    }
}