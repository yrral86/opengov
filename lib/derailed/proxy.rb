require 'drb'

module Derailed
  class Proxy < BasicObject
    def initialize(uri, key = nil)
      @proxy = ::DRbObject.new_with_uri uri
      @key = key
      # TODO support caching certain methods (apis, allowed_methods, etc)
      @@proxies[uri] = self
    end

    def self.fetch(uri, key = nil)
      @@proxies ||= {}
      if @@proxies[uri]
        return @@proxies[uri]
      else
        return self.new(uri,key)
      end
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
