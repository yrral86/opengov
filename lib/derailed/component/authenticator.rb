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

      # call handles routing the various paths to the functions to handle them
      def call(env)
        super(env, false)
        case path(1)
        when "login"
          login(env)
        when "logout"
          logout(env)
        when 'home'
          render_string("logged in username: #{current_user.username}, <a href='/logout'>logout</a>")
        when 'newuser'
          create_user(env)
        when 'edituser'
          edit_user(env)
        end
      end

      # login handles displaying the login form and processing its submission
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

      # login_fail displays the login form when login failed to authenticate
      # the user
      def login_fail(user_session)
        render_erb_from_file(view_file("newsession"),binding)
      end

      # login_success handles redirecting the user to their previously requested
      # url, or /home after they have successfully authenticated
      def login_success
        url = session[:onlogin]
        session[:onlogin] = nil
        url ||= "/home"
        redirect url
      end

      # logut destroys the user's session and sends them to the login form
      def logout(env)
        session = current_session
        session.destroy if session
        redirect "/login"
      end

      # create_user handles creating a new user.  At the moment, this can be
      # done by any logged in user.  This behavior should be modified before
      # deployment.
      def create_user(env)
        user = User.new(params['user'])
        if user.save
          UserSession.create(user)
          redirect '/home'
        else
          render_erb_from_file(view_file('newuser'),binding)
        end
      end

      # update_user allows the current user to update his/her user record
      def edit_user(env)
        user = current_user
        if user.update_attributes(params['user'])
          redirect '/home'
        else
          render_erb_from_file(view_file('edituser'),binding)
        end
      end
    end
  end
end
