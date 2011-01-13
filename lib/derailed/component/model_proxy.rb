module Derailed
  module Component
    class ModelProxy
      def self.initProxy(model)
        @proxy = Service.get_model model
      end

      def self.method_missing(id, *args)
        @proxy.send id, *args
      end
    end
  end
end
