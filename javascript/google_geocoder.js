var google_geocoder = {
    geocode: new google.maps.Geocoder().geocode,
    add_geocode: function() {
	var request = {address: $('add_address').address.value};
	google_geocoder.geocode(request, google_geocoder.submit);
    },
    submit: function(result, status) {
	if (status == google.maps.GeocoderStatus.OK) {
	    var street_number = '';
	    var street = '';
	    var city = '';
	    var state = '';
	    var zip = '';

	    // parse address from response
	    result[0].address_components.each(function(a) {
		    tags = a.types.toString();
		    value = a.short_name;
		    if (tags.match(/street_number/)) {
			street_number = value;
		    } else if (tags.match(/route/)) {
			street = value;
		    } else if (tags.match(/locality/)) {
			city = value;
		    } else if (tags.match(/administrative_area_level_1/)) {
			state = value;
		    } else if (tags.match(/postal_code/)) {
			zip = value;
		    }
		});

	    var address = street_number + ' ' + street;
	    if (address == ' ') {
		address = '';
	    }

	    new Ajax.Request('/map/update_address', {
		    parameters: {
			_ajax: 'yes',
			latitude: result[0].geometry.location.lat(),
			longitude: result[0].geometry.location.lng(),
			address: address,
			city: city,
			state: state,
			zip: zip,
			title: result[0].formatted_address
		    }
		});
	} else {
	    alert("could not geocode address");
	}
    }
}