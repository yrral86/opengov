module Derailed
  module API
    module Authenticator
      include API::Models
      include API::RackComponent
      include API::Session
      def all_officers; end
      def online_officers; end
      def offline_officers; end
    end
  end
end

