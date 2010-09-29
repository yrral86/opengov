require 'drb'

module Derailed
  class Proxy < BasicObject
    def initialize(uri, key = nil)
      @proxy = ::DRbObject.new_with_uri uri
      @key = key
      # TODO we can also check parameters locally if we need to reduce socket
      # traffic for InvalidAPI calls, although there shouldn't be many
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
