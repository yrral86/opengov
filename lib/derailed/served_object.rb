module Derailed
  class InvalidAPI < ::StandardError
    def initialize()
      super("The api you used is invalid")
    end
  end

  module API
    Util.autoload_dir(self, 'derailed/api')
  end

  ##
  # Feature: ServedObject
  #   As a component developer
  #   In order to securely provide functionality over DRb
  #   I want to lockdown the api
  ##
  # requires object to define allowed(key,id), authorized_methods, and debug
  class ServedObject < BasicObject
    def initialize(object, server_key, extensions=[])
      @object = object
      @server_key = server_key
      @apis = []
      extensions.each do |e|
        register_api(server_key,e,true)
      end
      generate_lists
      self
    end

    def method_call(key, id, *args)
#      @object.debug "#{@object.name}: method_call: id = #{id}"
      safely_handle(key, id) do
        if base_method?(id)
          result = self.__send__ id, *args
        else
          result = @object.send id, *args
        end
        # TODO: if result is DRb::DRbUndumped (or some other marker I switch to)
        # then make it a new ServedObject before returning
        # (what about DRbUndumped's that are not the object, but part of it
        #  such as a hash, where each value is Undumped or an array of
        #  Undumped objects)
        result
      end
    end

    def method_mising(id, *args)
      raise InvalidAPI, "method #{id} not valid for object of type #{name}"
    end

    def apis
      @apis
    end

    def allowed_methods
      allowed_hash.keys
    end

    def respond_to?(id)
      allowed_hash[id] && @object.allowed?(::Thread.current[:key], id)
    end

    def uri
      ::DRb.uri
    end

    def name
      @object.name
    end

    def inspect
      to_s
    end

    def register_api(object_key, api, no_gen = false)
      if object_key == @server_key
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

    def debug(msg)
      @object.debug msg
    end if Config::Environment == 'development' || Config::Environment == 'test'

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
      ::Thread.current[:key] = key
      if respond_to?(id)
        return yield
      else
        @object.debug "InvalidAPI: #{@object.name}: method_call: id = #{id}"
        ::Object.send(:raise, InvalidAPI)
      end
    end

    def allowed_hash
      @object.authorized_methods(::Thread.current[:key],
                                 @public_methods, @manager_methods)
    end

    def base_method?(id)
      methods = {}
      modules = [API::Base]
      modules << API::Development if Config::Environment == 'development'
      modules.each do |mod|
        mod.public_instance_methods.each do |method|
          methods[method] = true
        end
        mod.private_instance_methods.each do |method|
          methods[method] = true if allowed_hash[method]
        end
      end
      methods[id]
    end
  end
end
