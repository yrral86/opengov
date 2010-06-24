require 'drb'
require 'drb/unix'

class OpenGovDataComponent
  # model: The active record class
  def initialize(model)
    @model = model
    @component_manager = DRbObject.new nil, 'drbunix://tmp/opengovcomponentmanager.sock'
    socket = 'drbunix://tmp/opengov_' + self.model_name + '_datacomponent.sock'

    DRb.start_service socket, self
    trap("INT") {
      @component_manager.unregister_data_component(self.model_name)
      DRb.stop_service
    }
    @component_manager.register_data_component(socket)
  end

  def model_name
    @model.class.to_s
  end
end
