module Derailed
  module API
    module Authenticator
      include API::Models
      include API::RackComponent
      include API::Session
      def current_officers; end
    end
  end
end

