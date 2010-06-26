require 'drb'
require 'drb/unix'
require 'rubygems'
require 'active_record'

class OpenGovDataComponent
  # model: The active record class
  def initialize(name, *model)
    ActiveRecord::Base.establish_connection(
                                            :adapter => 'mysql',
                                            :host => '127.0.0.1',
                                            :database => 'opengov',
                                            :username => 'opengov',
                                            :password => 'crappass'
                                            )
    @name = name

    @models = {}
    model.each do |m|
      @models[m.name.to_s] = m
    end

    Class.send(:include, DRbUndumped)
    @component_manager = DRbObject.new nil, 'drbunix://tmp/opengovcomponentmanager.sock'
    socket = 'drbunix://tmp/opengov_' + @name + '_datacomponent.sock'

    DRb.start_service socket, self
    at_exit {
      @component_manager.unregister_data_component(@name)
      DRb.stop_service
    }

    @component_manager.register_data_component(socket)
    DRb.thread.join
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
end
