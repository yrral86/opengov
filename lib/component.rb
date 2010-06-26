require 'drb'
require 'drb/unix'
require 'rubygems'
require 'active_record'
require 'daemons'

require 'lib/componenthelper'

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
      @models[m.name.to_s] = m
    end

    @views = {}
    views.each do |v|
      @views[v.name.to_s] = v
    end

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
    @self
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
end
