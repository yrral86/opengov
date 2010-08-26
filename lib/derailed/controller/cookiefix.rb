module Derailed
  module Controller
    module CookieFix
      def delete(key, options = {})
        super(key)
      end
    end
  end
end
