require 'derailed/config'
require 'derailed/service'

module Derailed
  # = Derailed::ComponentClient
  # This class provides an interface to the components as well as the
  # Manager (possibly these two functionalities should be spilt)
  class ComponentClient
    # initialize creates a proxy for the Manager
    def initialize
      @cm = Service.get 'Manager'
    end

    # get_current_session invokes current_session on the Authenticator component
    # which is a subclass of Derailed::Component::Authenticator.  This method
    # returns the current authenticated session if the user is logged in and
    # nil otherwise
    def get_current_session(env)
      get_component('Authenticator').current_session(env)
    end

    # get_routes invokes the available_routes method on the Manager.
    # If the call fails, an empty hash is returned
    def get_routes
      begin
        @cm.available_routes
      rescue DRb::DRbConnError
        {}
      end
    end

    # get_model returns the model given by name.
    # Name uses the following format ComponentName::modelname.
    # Models are DRbUndumped so we really return a DRbObject that references
    # the model.
    def get_model(name)
      component, model = name.split '::'
      get_component(component).model(model)
    end

    # get_component returns a proxy for the component specified by name
    def get_component(name)
      Service.get (name)
    end

    # dependencies_not_satisfied returns a list of unsatisfied dependencies
    # when given a list of dependencies.  In other words, it removes all
    # dependencies from the list which are met.  If the returned hash is empty
    # all dependencies are satisfied.
    def dependencies_not_satisfied(deps)
      available = {}
      @cm.available_components.each do |c|
        available[c] = true
      end
      not_available = []
      deps.each do |d|

        unless available[d]
          not_available << d
        end
      end
      not_available
    end

    # cm is an accessor for the Manager
    def cm
      @cm
    end
  end
end
