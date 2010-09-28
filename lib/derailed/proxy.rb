module Derailed
  class Proxy < BasicObject
    def initialize(object, key = nil)
      @proxy = object
      @key = key
      self
    end

    def method_missing(id, *args)
      @proxy.method_call(@key, id, *args)
    end
  end
end
