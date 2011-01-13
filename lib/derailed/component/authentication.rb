module Derailed
  module Component
    # = Derailed::Component::Authentication
    # This module provides functions to initialize the environment on a new
    # request (setup_env), get the current session from the Authenticator
    # module (current_session), and get the current user for that session
    # (current_user)
    module Authentication
      # setup_env sets the environment variable for the current thread
      # and also initializes the controller for Authlogic (see
      # Derailed::Component::Controller)
      def setup_env(env)
        Thread.current[:env] = env
      end

      # current_session fetches the current session via
      # Derailed::Client.get_current_session
      def current_session
        begin
          @authenticator.current_session(Thread.current[:env])
        rescue => e
          @logger.backtrace e
        end
      end

      # current_user extracts the user from the current session
      def current_user
        s = current_session
        s && s.record
      end

      def online_officers
        @authenticator.online_officers
      end
      
      def offline_officers
        @authenticator.offline_officers
      end

      def all_officers
        @authenticator.all_officers
      end
    end
  end
end
