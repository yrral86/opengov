require 'drb'
require 'drb/unix'
require 'rubygems'
require 'active_record'

class OpenGovDataComponent
  # model: The active record class
  def initialize(model)
    ActiveRecord::Base.establish_connection(
                                            :adapter => 'mysql',
                                            :host => '127.0.0.1',
                                            :database => 'opengov',
                                            :username => 'opengov',
                                            :password => 'crappass'
                                            )

    @model = model
    @component_manager = DRbObject.new nil, 'drbunix://tmp/opengovcomponentmanager.sock'
    socket = 'drbunix://tmp/opengov_' + self.model_name + '_datacomponent.sock'

    DRb.start_service socket, self
    at_exit {
      @component_manager.unregister_data_component(self.model_name)
      DRb.stop_service
    }

    @component_manager.register_data_component(socket)
    DRb.thread.join
  end

  def model_name
    @model.name.to_s
  end
end
