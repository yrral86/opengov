#!/usr/bin/seed
Gtk = imports.gi.Gtk;
//Champlain = imports.gi.Champlain;
//GtkChamplain = imports.gi.GtkChamplain;
GtkBuilder = imports.gtkbuilder;
//GtkClutter = imports.gi.GtkClutter;
//Clutter = imports.gi.Clutter;
WebKit = imports.gi.WebKit;
//DBus = imports.gi.DBus;
//DBus = imports.dbus;
Soup = imports.gi.Soup;

handlers = {
    on_window_destroy: function(window) {
	Seed.quit();
    }
};

OpenGovUI = new GType({
	parent: Gtk.Builder.type,
	name: "OpenGovUI",
	init: function(klass) {
	    this.add_from_file("ui.glade");
	    this.connect_signals(handlers);

	    var window = this.get_object("main_window");

	    var scrolled_window = new Gtk.ScrolledWindow();
	    var web_view = new WebKit.WebView();
	    window.add(scrolled_window);
	    scrolled_window.add(web_view);

	    this.update_uri = function (uri) {
		web_view.load_uri(uri);
	    }

	    
	    this.update_uri("http://maps.google.com");
	    
	    window.show_all();

	    Gtk.timeout_add(1000, function (data) {
		    web_view.execute_script("alert(document.title);");
		    return false;
		});

	    web_view.signal.script_alert.connect(function (view, frame, message) {
		    print(message);
		    return true;
		});
	}
    });


Gtk.init(Seed.argv);
ui = new OpenGovUI();

server = new Soup.Server({port: 12345});
server.add_handler("/", function(server, message, path, query, client, data) {
	message.set_status(Soup.KnownStatusCode.OK);
	message.set_response("text/html", Soup.MemoryUse.COPY, null, 0);
	
	switch (path.substr(1)) {
	case 'maps':
	    ui.update_uri('http://maps.google.com');
	    break;
	case 'news':
	    ui.update_uri('http://news.google.com');
	    break;
	case 'slashdot':
	    ui.update_uri('http://www.slashdot.org');
	    break;
	case 'pgo':
	    ui.update_uri('http://planet.gnome.org');
	    break
	case 'google':
	default:
	    ui.update_uri('http://www.google.com');
	}
    }, null, null);


print("Starting soup server on port " + server.get_port());
server.run_async();

//bus = DBus.session;
//dbus = bus.get_object("org.freedesktop.DBus");
//dbus.request_name("org.opengov.ui", null);

//bus.exports.org.opengov.ui = new OpenGovUI();

/*
b = new Gtk.Builder();
b.add_from_file("ui.glade");
b.connect_signals(handlers);

w = b.get_object("main_window");
*/

/*
// champlain map
map = new GtkChamplain.Embed();
w.add(map);

view = map.get_view();
view.set_size(640, 480);
view.center_on(39.9417267, -80.7543844);
view.set_zoom_level(16);
view.set_scale_unit(Champlain.Unit.MILES);
view.set_show_scale(true);
view.set_scroll_mode(Champlain.ScrollMode.KINETIC);

text = new Clutter.Text();
text.set_text("Test Text");
text.set_position(100,100);
//view.container_add(text);


layer = new Champlain.SelectionLayer();
m = new Champlain.Marker();
m.set_text("Test Marker");
m.set_position(39.9417267, -80.7543844);
//m.set_text_color(new Clutter.Color(0,255,0));
layer.add_marker(m);
view.add_layer(layer);
layer.show();
layer.show_all_markers();
*/

Gtk.main();
