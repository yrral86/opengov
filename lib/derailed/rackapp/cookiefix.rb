module Derailed
  module RackApp
    # = Derailed::RackApp::CookieFix
    # This module overrides the delete method because Authlogic expect cookie's
    # delete method to take two arguments
    module CookieFix
      # delete overrides the hash's delete method to allow two options so
      # authlogic is happy.
      def delete(key, options = {})
        super(key)
      end
    end
  end
end
