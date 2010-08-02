require 'drb'
require 'drb/unix'
require 'rubygems'
require 'action_controller'
require 'active_record'
require 'authlogic'
require 'daemons'
require 'rack/request'
require 'rack/logger'

dir = File.expand_path(File.dirname(__FILE__))

require dir + '/componenthelper'
require dir + '/view'

# SHOULD BE IN A CONFIG FILE SOMEWHERE
module Config
  RootDir = File.expand_path(File.dirname(__FILE__)) + '/../'
  Environment = 'development'
end

class OpenGovComponent
  def initialize(name, models, views, dependencies = [])
    @registered = false;
    database_yml = YAML::load(File.open(Config::RootDir + '/db/config.yml'))
    ActiveRecord::Base.logger = Logger.new STDOUT
    ActiveRecord::Base.establish_connection(database_yml[Config::Environment])
    @name = name
    @dependencies = dependencies

    @models = {}
    models.each do |m|
      m.extend(DRbUndumped)
      @models[m.name.downcase] = m
    end

#    not yet used
#    @views = {}
#    views.each do |v|
#      @views[v.name.downcase] = v
#    end


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

  def setup_env(env)
    Thread.current[:env] = env
    Authlogic::Session::Base.controller = controller
  end

  def controller
    Thread.current[:env][:controller]
  end

  def session
    controller.session
  end

  def params
    controller.params
  end

  def path(n)
    controller.path(n)
  end

  def next_path
    controller.next
  end

  def current_user
    s = UserSession.find
    s && s.record
  end

  def call(env)
    setup_env(env)
    model_name = next_path
    id = next_path
    r = controller.request

    model = @models[model_name]

    if model then
      if r.post? then
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
          render_form(model,next_path)
        else
          read(model,id)
        end
      elsif r.delete? then # IN CASE WE EVER USE THE ACTUAL METHODS
        delete(model,id) # INSTEAD OF TUNNELING OVER POST
      elsif r.put? then
        update(model,r)
      else
        OpenGovView.method_not_allowed
      end
    else
      unless model_name then
        model_name = 'Nil'
      end
      OpenGovView.not_found('Model ' +
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
      OpenGovView.redirect('/' + @name.downcase +
                           '/' + model.name.downcase +
                           '/' + object.id.to_s)
    else
      render_form(model, nil)
    end
  end

  def read(model, id)    
    object = model.find_by_id(id)
    if object then
      OpenGovView.render_erb_from_file(view_file(model.name.downcase),binding)
    elsif id then
      OpenGovView.not_found('Record  #' + id + ' not found for model ' +
                            model.name + ' in component ' + @name)
    else
      objects = model.find :all
      OpenGovView.render_erb_from_file(view_file(model.name.downcase + 'list'),
                                       binding)
    end
  end

  def render_form(model,id)
    if id then
      object = model.find_by_id(id)
      method = 'put'
    else
      object = model.new
      method = 'post'
    end
    OpenGovView.render_erb_from_file(view_file(model.name.downcase + 'form'),
                                     binding)
  end

  def update(model, request)
    id = request.path.split("/")[3]
    object = model.find_by_id(id)
    if object
      params = clean_params(model, request.params)
      if object.update_attributes(params) then
        OpenGovView.redirect('/' + @name.downcase +
                             '/' + model.name.downcase +
                             '/' + id)
      else
        render_form(model, id)
      end
    else
      OpenGovView.not_found('Record # ' +
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
      OpenGovView.redirect('/' + @name.downcase +
                           '/' + model.name.downcase)
    else
      OpenGovView.not_found('Record # ' +
                            id +
                            ' not found for model ' +
                            model.name +
                            'in component ' +
                            @name)
    end
  end
  
  def view_file(name)
    Config::RootDir + '/' +
      'components' + '/' +
      @name.downcase + '/' +
      'v' + '/' +
      name + '.html.erb'
  end

  def render(name, binding)
    OpenGovView.render_erb_from_file_to_string(view_file('_' + name), binding)
  end
end
