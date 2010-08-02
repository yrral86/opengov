require 'drb'

class OpenGovComponentHelper
  def initialize
    @cm = DRbObject.new nil, 'drbunix://tmp/opengovcomponentmanager.sock'
  end

  def get_current_session(env)
    a = get_component('Authenticator')
    a.current_session(env)
  end

  def get_routes
    begin
      @cm.available_routes
    rescue DRb::DRbConnError
      {}
    end
  end

  def get_model(name)
    component, model = name.split '::'
    get_component(component).model(model)
  end

  def get_component(name)
    DRbObject.new nil, @cm.get_component_socket(name)
  end

  def dependencies_not_satisfied(deps)
    available = {}
    @cm.available_components.each do |c|
      available[c] = true
    end
    not_available = []
    deps.each do |d|

      unless available[d] then
        not_available << d
      end
    end
    not_available
  end

  def cm
    @cm
  end
end
