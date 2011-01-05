function include(file) {
    var external = new RegExp('^http://');
    var src;
    if (external.test(file)) {
	src = file;
    } else {
	src = '/static/javascript/' + file;
    }
    document.write('<script type="text/javascript" src="' +
		   src + '"></scr' + 'ipt>');
    // close script tag has to be split do to IE7 bug
};

include('prototype.js');
include('scriptaculous.js?load=builder,effects');
include('modalbox.js');

function delete_object(id, url) {
    new Ajax.Request(url + '/' + id, {
	    method:'delete',
            onSuccess: function(response) {
		if (response.status == 302) {
		    document.location.href = url;
		}
	    }
    });
}

function share_object(id, url) {
    Modalbox.show(url + '_share/' + id, {title: 'Share',
		params: { _ajax: 'yes' }});
}

function add_object(id, url) {
    new Ajax.Request(url + '_add/' + id, {
	    parameters: { _ajax: 'yes' }});
}

function update_div(id, url) {
    new Ajax.Updater(id, url, {
	    parameters: { _ajax: 'yes' }
    });
}

function poll_to_div(id, url) {
    // NOTE: automatically reissues request on HTTP 408 (server timeout)
    new Ajax.Request(url, {
	    method: "get",
            parameters: {_ajax: 'yes'},
	    onSuccess: function(response) {
		if (response.responseText != '' &&
		    response.status != 0) {
		    $(id).replace('<div id="' + id + '">' +
				  response.responseText + '</div>');
		}
		if (response.status != 0) {
		    poll_to_div(id, url);
		}
	    },
	    onFailure: function(response) {
		// request failed... wait 1 second before trying again
		setTimeout(function() {poll_to_div(id, url);}, 1000);
	    }
    });
}