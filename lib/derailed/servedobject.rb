module Derailed
  class InvalidAPI < ::StandardError
    def initialize()
      super("The api you used is invalid")
    end
  end

  module API
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

  class ServedObject# < BasicObject
    def initialize(object, object_key, extensions=[])
      @object = object
      @object_key = object_key
      @apis = []
      extensions.each do |e|
        register_api(object_key,e,true)
      end
      generate_lists
      self
    end

    def method_call(key, id, *args)
      safely_handle(key, id) do
        @object.send id, *args
      end
    end

    def method_mising(id, *args)
      raise InvalidAPI
    end

    def apis
      @apis
    end

    def allowed_methods
      allowed_hash.keys
    end

#    def private_methods
#      []
#    end

#    def protected_methods
#      []
#    end

    def register_api(object_key, api, no_gen = false)
      if object_key == @object_key
        @apis << api
        @rules = generate_lists unless no_gen
      else
        raise InvalidAPI
      end
    end

    def allowed?(id)
      allowed_hash[id]
    end

 #   def to_s
 #     @object.name
 #   end

    private
    def generate_lists
      @public_methods = {}
      @manager_methods = {}
      @apis.each do |api|
        api.public_instance_methods.each do |m|
          @public_methods[m] = true
          @manager_methods[m] = true
        end
        api.private_instance_methods.each do |m|
          @manager_methods[m] = true
        end
      end
    end

    def safely_handle(key, id)
      # TODO: Proxy.get
      @scope = Service.get('Manager').check_key(key)
      result = yield if allowed?(id)
      @scope = nil
      result
    end

    def allowed_hash
      @scope == :private ? @manager_methods : @public_methods
    end
  end
end

