require 'drb'

class OpenGovComponentHelper
  def initialize
    @cm = DRbObject.new nil, 'drbunix://tmp/opengovcomponentmanager.sock'
  end

  def get_model(name)
    component, model = name.split '::'
    DRbObject.new(nil, @cm.get_data_component_socket(component)).model(model)
  end

  def cm
    @cm
  end
end
