function include(file) {
    document.write('<script type="text/javascript" src="/static/javascript/' +
		   file + '"></scr' + 'ipt>');
	// close script tag has to be split do to IE7 bug
};

include('prototype.js');

function delete_object(id, url) {
    new Ajax.Request(url + '/' + id, {
	    method:'delete',
		onSuccess: function(response) {
		document.location.href = url;
	    }
    });
}

function update_div(id, url) {
    new Ajax.Updater(id, url, {
	    parameters: { _ajax: 'yes' }
    });
}