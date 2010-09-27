module Derailed
  class API < BasicObject
    def initialize(component, extensions=[])
      @component = component
      @apis = []
      extenstions.each do |e|
        register_api(e,true)
      end
      generate_lists
      self
    end

    private
    def generate_lists
      @public_methods = {}
      @private_methods = {}
      @apis.each do |api|
        api.public_instance_methods.each do |m|
          @public_methods[m] = 1
        end
        api.private_instance_methods.each do |m|
          @private_methods[m] = 1
        end
      end
    end

    def register_api(api, no_gen = false)
      @apis << api
      @rules = generate_rules unless no_gen
    end

    [
     'Authenticator',
     'Base',
     'Models',
     'Testing',
     'Rack'
    ].each do |library|
      autoload library.to_sym, "derailed/api/#{library.downcase}"
    end
  end
end

