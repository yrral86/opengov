module Derailed
  class Proxy < BasicObject
    def intialize(object, name, key = nil)
      @proxy = object
      @name = name
      @key = key
    end

    def method_missing(id, *args)
      @proxy.method_call(@key, id, *args)
    end

    def proxy
      @proxy
    end
  end
end
