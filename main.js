#!/usr/bin/seed
Gtk = imports.gi.Gtk;
Champlain = imports.gi.Champlain;
GtkChamplain = imports.gi.GtkChamplain;
GtkBuilder = imports.gtkbuilder;
GtkClutter = imports.gi.GtkClutter;
Clutter = imports.gi.Clutter;
WebKit = imports.gi.WebKit;

handlers = {
    on_window_destroy: function(window) {
	Seed.quit();
    }
};

GtkClutter.init(Seed.argv);

b = new Gtk.Builder();
b.add_from_file("ui.glade");
b.connect_signals(handlers);

w = b.get_object("main_window");
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


// WebKitGtk
scrolled_window = new Gtk.ScrolledWindow();
web_view = new WebKit.WebView();
w.add(scrolled_window);
scrolled_window.add(web_view);

web_view.load_uri("http://maps.google.com");


w.show_all();

Gtk.main();
