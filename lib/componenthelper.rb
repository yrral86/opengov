require 'drb'

class OpenGovComponentHelper
  def initialize
    @cm = DRbObject.new nil, 'drbunix://tmp/opengovcomponentmanager.sock'
  end

  def get_model(name)
    DRbObject.new(nil, @cm.get_data_component_socket(name)).model
  end

  def cm
    @cm
  end
end
