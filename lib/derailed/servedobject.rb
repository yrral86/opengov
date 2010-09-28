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

  class ServedObject < BasicObject
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
#      @object.debug "#{@object.name}: method_call: id = #{id}"
      safely_handle(key, id) do
        if base_method?(id)
          self.__send__ id, *args
        else
          @object.send id, *args
        end
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

    def allowed?(id)
      allowed_hash[id]
    end

    def name
      @object.name
    end

    def register_api(object_key, api, no_gen = false)
      if object_key == @object_key
        @apis << api
        @rules = generate_lists unless no_gen
      else
        ::Object.send(:raise, InvalidAPI)
      end
    end

    # for puts
    def to_s
      @object.to_s
    end

    # for puts
    def to_ary
      nil
    end

    ## rest of public methods are to make drb happy
    def private_methods
      []
    end

    def protected_methods
      []
    end

    def __id__
      @object.__id__
    end

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
      @object.key = key
      if allowed?(id)
        @object.key = nil
        return yield
      else
        @object.key = nil
        ::Object.send(:raise, InvalidAPI)
      end
    end

    def allowed_hash
      @object.authorized? ? @manager_methods : @public_methods
    end

    def base_method?(id)
      methods = {}
      API::Base.public_instance_methods.each do |m|
        methods[m] = true
      end
      API::Base.private_instance_methods.each do |m|
        methods[m] = true if allowed_hash[m]
      end
      methods[id]
    end
  end
end

