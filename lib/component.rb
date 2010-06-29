require 'drb'
require 'drb/unix'
require 'rubygems'
require 'active_record'
require 'daemons'
require 'erb'
require 'rack/request'
require 'rack/response'
require 'rack/logger'

require 'lib/componenthelper'

# SHOULD BE IN A CONFIG FILE SOMEWHERE
module Config
  RootDir = "/home/larry/Projects/opengov"
end  

class OpenGovComponent
  # model: The active record class
  def initialize(name, models, views, dependencies = [])
    @registered = false;
    ActiveRecord::Base.establish_connection(
                                            :adapter => 'mysql',
                                            :host => '127.0.0.1',
                                            :database => 'opengov',
                                            :username => 'opengov',
                                            :password => 'crappass'
                                            )
    @name = name
    @dependencies = dependencies

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
    need = @ch.dependencies_not_satisfied(@dependencies)
    if need == [] then
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
    else
      p 'Dependencies not met: ' + need.join(",")
      exit
    end
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
    @logger = env['rack.errors']

    model = @models[path[2]]
    id = path[3]

    if model then
      if r.post? then
        @logger.write "_method: " + r.params['_method'].to_s + "\n"
        case r.params['_method']
          when 'put' # UPDATE
          update(model,r)
          when 'delete' # DELETE
          delete(model,id)
          else # CREATE
          create(model,r)
        end
      elsif r.get? then # READ
        if id == 'edit' then
          read_form(model,path[4])
        else
          read(model,id)
        end
      elsif r.delete? then # IN CASE WE EVER USE THE ACTUAL METHODS
        delete(model,id) # INSTEAD OF TUNNELING OVER POST
      elsif r.put? then
        update(model,r)
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

  def clean_params(model, params)
    new_params = {}
    attributes = model.new.attributes.keys - model.protected_attributes.to_a
    attributes.each do |a|
      if params[a] then
        new_params[a] = params[a]
      end
    end
    new_params
  end

  def create(model, request)
    params = clean_params(model, request.params)
    object = model.new(params)
    # MODEL NEEDS VALIDATION OF SOME SORT OTHERWISE WE
    # WILL FALL THROUGH AND CREATE A NULL FILLED RECORD
    # INSTEAD OF DISPLAYING THE FORM
    if object.save then
      redirect('/' + @name.downcase +
               '/' + model.name.downcase +
               '/' + object.id.to_s)
    else
      read_form(model, nil)
    end
  end

  def read(model, id)    
    object = model.find_by_id(id)
    if object then
      html_view(model.name.downcase,binding)
    elsif id then
      not_found('Record  #' + id + ' not found for model ' +
                model.name + ' in component ' + @name)
    else
      objects = model.find :all
      html_view(model.name.downcase + 'list', binding)
    end
  end

  def read_form(model,id)
    if id then
      object = model.find_by_id(id)
      method = 'put'
    else
      object = model.new
      method = 'post'
    end
    html_view(model.name.downcase + 'form', binding)
  end

  def update(model, request)
    id = request.path.split("/")[3]
    object = model.find_by_id(id)
    if object
      params = clean_params(model, request.params)
      if object.update_attributes(params) then
        redirect('/' + @name.downcase +
                 '/' + model.name.downcase +
                 '/' + id)
      else
        read_form(model, id)
      end
    else
      not_found('Record # ' +
                id.to_s +
                ' not found for model ' +
                model.name +
                'in component ' +
                @name)
    end
  end
  
  def delete(model, id)
    object = model.find_by_id(id)
    if object then
      object.delete
      redirect('/' + @name.downcase +
               '/' + model.name.downcase)
    else
      not_found('Record # ' +
                id +
                ' not found for model ' +
                model.name +
                'in component ' +
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

  def html_view(name, b)
    string = render_template(name, b)
    if string != -1 then
      [200,
       {'Content-Type' => 'text/html'},
       [string]
      ]
    else
      not_found("Template " + name + " not found in controller " + @name)
    end
  end

  def render_template(name, b)
    begin
      fn = Config::RootDir + '/' +
        'components' + '/' +
        @name.downcase + '/' +
        'v' + '/' +
        name + '.rhtml'
      ERB.new(File.read(fn)).result b
    rescue Exception => e
      @logger.write "Error reading/processing template: " +  e.message + "\n"
      @logger.write "Exception class: " + e.class.name + "\n"
      -1
    end
  end
end
