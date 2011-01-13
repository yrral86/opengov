module Derailed
  module Component
    class ModelProxy
      def self.initProxy(model)
        @@model = model
      end

      def self.method_missing(id, *args)
        self.proxy.send id, *args
      end

      private
      def self.proxy
        @@proxy ||= Service.get_model @@model
      end
    end
  end
end
