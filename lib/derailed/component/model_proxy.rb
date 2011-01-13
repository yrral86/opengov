module Derailed
  module Component
    class ModelProxy
      def self.initProxy(model)
        @@model = model
        @@m = Mutex.new
      end

      def self.method_missing(id, *args)
        self.proxy.send id, *args
      end

      private
      def self.proxy
        @@proxy ||= @@m.synchronize do
          # The proxy is only good for as long as the DRbTimeout,
          # so expire it at 90% of that
          t = Thread.new do
            sleep 0.9*Config::DRbTimeout
            @@proxy = nil
          end
          # we need the sleep to start right away, othewise it could overrun
          # the timeout and we would have an invalid @@proxy object
          Thread.pass until t.status == 'sleep'
          # bookkeeping done, get the model
          Service.get_model @@model
        end
      end
    end
  end
end
