module Derailed
  module Component
    class Authenticator < Base
      def routes
        # /home is temporary
        ['login', 'logout', 'home', 'newuser', 'edituser']
      end

      def current_session(env=Thread.current[:env])
        Authlogic::Session::Base.controller = env[:controller]
        UserSession.find
      end

      def call(env)
        super(env, false)
        case path(1)
        when "login"
          login(env)
        when "logout"
          logout(env)
        when 'home'
          View.render_string("logged in username: #{current_user.username}, <a href='/logout'>logout</a>")
        when 'newuser'
          create_user(env)
        when 'edituser'
          edit_user(env)
        end
      end

      def login(env)
        session_params = params['user_session']

        if session_params
          if User.find_by_pam_login(session_params['username'])
            pam_params = {:pam_login => session_params['username'],
              :pam_password => session_params['password']}
            new_session = UserSession.new pam_params
          else
            new_session = UserSession.new session_params
          end

          if new_session.save
            login_success
          else
            login_fail(new_session)
          end
        else
          new_session = UserSession.new
          login_fail(new_session)
        end
      end

      def login_fail(user_session)
        View.render_erb_from_file(view_file("newsession"),binding)
      end

      def login_success
        url = session[:onlogin]
        session[:onlogin] = nil
        url ||= "/home"
        View.redirect url
      end

      def logout(env)
        session = current_session
        session.destroy if session
        View.redirect "/login"
      end

      def create_user(env)
        user = User.new(params['user'])
        if user.save
          UserSession.create(user)
          View.redirect '/home'
        else
          View.render_erb_from_file(view_file('newuser'),binding)
        end
      end

      def update_user(env)
        user = current_user
        if user.update_attributes(params['user'])
          View.redirect '/home'
        else
          View.render_erb_from_file(view_file('edituser'),binding)
        end
      end

    end
  end
end
