require 'authlogic_pam'

require 'derailed/component/authenticatorcontroller'

module Derailed
  module Component
    # = Derailed::Component::Authenticator
    # This class is the base for an Authenticator component using Authlogic.
    # It provides /login, /logout, /home (for now), /newuser, and /edituser
    class Authenticator < Base
      # routes (as in any component) provides the routes this component services
      def routes
        # /home is temporary
        ['login', 'logout', 'home', 'newuser', 'edituser']
      end

      # current_session provides the current authenticated session if the user
      # is logged in, and nil otherwise
      def current_session(env=Thread.current[:env])
        Authlogic::Session::Base.controller = env[:controller]
        UserSession.find
      end

      # call invokes Component::Base.call with a value of 1 for the
      # path_position
      def call(env)
        super(env,1)
      end

      def setup_env(env)
        super(env)
        Authlogic::Session::Base.controller = controller
      end
    end
  end
end
