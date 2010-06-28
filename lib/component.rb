require 'drb'
require 'drb/unix'
require 'rubygems'
require 'active_record'
require 'daemons'
require 'erb'
require 'rack/request'
require 'rack/response'

require 'lib/componenthelper'

# SHOULD BE IN A CONFIG FILE SOMEWHERE
module Config
  RootDir = "/home/larry/Projects/opengov"
end  

class OpenGovComponent
  # model: The active record class
  def initialize(name, models, views)
    @registered = false;
    ActiveRecord::Base.establish_connection(
                                            :adapter => 'mysql',
                                            :host => '127.0.0.1',
                                            :database => 'opengov',
                                            :username => 'opengov',
                                            :password => 'crappass'
                                            )
    @name = name

    @models = {}
    models.each do |m|
      @models[m.name.downcase] = m
    end

#    not yet used
#    @views = {}
#    views.each do |v|
#      @views[v.name.downcase] = v
#    end

    Class.send(:include, DRbUndumped)

    @ch = OpenGovComponentHelper.new

    socket = 'drbunix://tmp/opengov_' + @name + '_component.sock'
    DRb.start_service socket, self
    @ch.cm.register_component(socket)
    @registered = true
    at_exit {
      if @registered then
        @ch.cm.unregister_component(@name)
      end
      DRb.stop_service
      ActiveRecord::Base.remove_connection
    }
    self
  end

  def unregistered
    @registered = false
  end

  def model_names
    @models.keys
  end

  def model(name)
    @models[name]
  end

  def name
    @name
  end

  def stop
    p 'component manager shutting down, exiting ' + self.class.name.to_s
    # need to figure out magic to properly kill daemon
  end

  def daemonize
    DRb.thread.join
  end

  def routes
    [@name.downcase]
  end

  def call(env)
    r = Rack::Request.new(env)
    path = r.path.split "/"

    model = @models[path[2]]
    id = path[3]

    if model then
      if r.post? then # CREATE
        object = model.new(r.params)
        # MODEL NEEDS VALIDATION OF SOME SORT OTHERWIsE WE
        # WILL FALL THROUGH AND CREATE A NULL FILLED RECORD
        # INSTEAD OF DISPLAYING THE FORM
        if object.save then
          redirect('/' + @name.downcase +
                            '/' + model.name.downcase +
                            '/' + object.id.to_s)
        else
          string_view('Component ' +
                      @name +
                      ' serving edit form for a new record for the model ' +
                      model.name)
        end
      elsif r.get? then # READ
        object = model.find_by_id(id)
        if object then
          html_view(model.name.downcase,binding)
        else
          string_view('Component ' +
                      @name +
                      ' serving list of records for model ' +
                      model.name +
                      '<form method="POST"><input type="hidden" name="fname" value="Larry" /><input type="hidden" name="lname" value="Reaves" /><input type="submit"/></form>')
        end
      elsif r.put? then # UPDATE
        object = model.find_by_id(id)
        if object
          # need help here
          # should either display form, or update object
          # maybe we need a url bifurcation here
          # unless Bill knows the magical incantation
          string_view('Component ' +
                      @name +
                      ' serving edit form for an existing record for ' +
                      'the model ' + model.name)
        else
          not_found('Record # ' +
                    id +
                    ' not found for model ' +
                    model.name +
                    'in component ' +
                    @name)
        end
      elsif r.delete? then # DELETE
        object = model.find_by_id(id)
        if object then
          object.delete
          redirect('/' + @name.downcase +
                   '/' + model.name.to_s)
        else
          not_found('Record # ' +
                    id +
                    ' not found for model ' +
                    model.name +
                    'in component ' +
                    @name)
        end
      else
        [405, {'Content-Type' => 'text/html'}, ['Method Not Allowed']]
      end
    else
      model_name = path[2]
      unless model_name then
        model_name = 'Nil'
      end
      not_found('Model ' +
                model_name +
                ' not found in component ' +
                @name)
    end
  end

  def redirect(url)
    response = Rack::Response.new
    response.redirect(url)
    response.finish
  end

  def not_found(msg)
    [404, {'Content-Type' => 'text/html'}, [msg]]
  end

  def string_view(msg)
          [200,
           {'Content-Type' => 'text/html'},
           [msg]]
  end

  def html_view(name, binding)
    [200,
     {'Content-Type' => 'text/html'},
     [render_template(name, binding)]
    ]
  end

  def render_template(name, binding)
    template = File.read(Config::RootDir + '/' +
                         'components' + '/' +
                         @name.downcase + '/' +
                         'v' + '/' +
                         name + '.rhtml')
    ERB.new(template).result(binding)
  end
end
