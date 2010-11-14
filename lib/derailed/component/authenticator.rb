require 'authlogic_pam'

require 'derailed/component/authenticator/controller'

module Derailed
  module Component
    # = Derailed::Component::Authenticator
    # This class is the base for an Authenticator component using Authlogic.
    # It provides /login, /logout, /home (for now), /newuser, and /edituser
    class Authenticator < Base
      def initialize(*args)
        super(*args)
        @served_object.register_api(@served_key, API::Authenticator)
        @sessions = {}
        @refresh_sessions = {}
      end

      # routes (as in any component) provides the routes this component services
      def routes
        # /home is temporary
        ['login', 'logout', 'home', 'newuser', 'edituser']
      end

      # current_session provides the current authenticated session if the user
      # is logged in, and nil otherwise
      def current_session(env=Thread.current[:env])
        return nil unless env
        setup_env(env)
        key = session['user_credentials']
        if @sessions[key]
          @refresh_sessions[key] = true
        else
          s = find_session
          key = session['user_credentials']
          @sessions[key] = s
          @refresh_sessions[key] = true
          Thread.new do
            while @refresh_sessions[key] do
              @refresh_sessions.delete(key)
              sleep Config::SessionTimeout
            end
            @sessions.delete(key)
          end
          params['_need_cookie_update'] = true if full_path == '/ajax/poll'
        end
        s = @sessions[key]
        @logger.debug full_path
        @logger.debug s.inspect
        s
      end

      def find_session
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
