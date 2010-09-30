module Derailed
  module API
    module Authenticator
      include API::Models
      include API::RackComponent
      include API::Session
    end
  end
end

