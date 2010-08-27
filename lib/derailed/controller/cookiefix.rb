module Derailed
  module Controller
    # = Derailed::Controller::CookieFix
    # This module overrides the delete method because Authlogic expect cookie's
    # delete method to take two arguments
    module CookieFix
      def delete(key, options = {})
        super(key)
      end
    end
  end
end
