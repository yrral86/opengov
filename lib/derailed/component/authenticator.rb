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
        # @previous_sessions[old_session_key] = new_session_key
        @previous_sessions = {}
        @refresh_sessions = {}
        @session_mutex = Mutex.new
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
          @session_mutex.synchronize do
            unless @previous_sessions[key]
              oldkey = key
              s = find_session
              key = session['user_credentials']
              @previous_sessions[oldkey] = key
              @sessions[key] = s
              @refresh_sessions[key] = true
              Thread.new do
                sleep Config::PreviousSessionTimeout
                 @previous_sessions.delete(oldkey)
              end
              Thread.new do
                while @refresh_sessions[key] do
                  @refresh_sessions.delete(key)
                  sleep Config::SessionTimeout
                end
                @sessions.delete(key)
              end
              params['_need_cookie_update'] = true if full_path == '/ajax/poll'
            else
              key = @previous_sessions[key]
            end
          end
        end
        @sessions[key]
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
