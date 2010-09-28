module Derailed
  class Proxy < BasicObject
    def initialize(object, key = nil)
      @proxy = object
      @key = key
      self
    end

    def method_missing(id, *args)
      # TODO begin rescue DRb::DRbConnError end
      # Once we are turning DRbUndumped objects into ServedObject's
      # we should check here for a ServedObject and return a proxy
      # instead
      @proxy.method_call(@key, id, *args)
    end
  end
end
