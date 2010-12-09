module Derailed
  module Component
    # = Derailed::Component::AuthenticatorController
    # This class subclasses Controller to provide the default actions for
    # an Authenticator component.
    class AuthenticatorController < Controller
      # login handles displaying the login form and processing its submission
      def login
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

      # logut destroys the user's session and sends them to the login form
      def logout
        session = @component.current_session
        @component.logger.debug "session fetched, destroying"
        begin
          session.destroy if session
        rescue => e
          @component.logger.backtrace e
        end
        @component.logger.debug "session destroyed, redirecting"
        redirect "/login"
      end

      # newuser handles creating a new user.  At the moment, this can be
      # done by any logged in user.  This behavior should be modified before
      # deployment.
      def newuser
        user = User.new(params['user'])
        if user.save
          UserSession.create(user)
          redirect '/home'
        else
          render('newuser', binding)
        end
      end

      # edituser allows the current user to update his/her user record
      def edituser
        user = current_user
        if user.update_attributes(params['user'])
          redirect '/home'
        else
          render('edituser', binding)
        end
      end

      # home renders the username and a logout link... this is temporary
      def home
        render_string "logged in username: " +
          "#{@component.current_user.username}, <a href='/logout'>logout</a>"
      end

      private
      # login_fail displays the login form when login failed to authenticate
      # the user
      def login_fail(user_session)
        render("newsession", binding)
      end

      # login_success handles redirecting the user to their previously requested
      # url, or /home after they have successfully authenticated
      def login_success
        url = session[:onlogin]
        session[:onlogin] = nil
        url ||= "/home"
        redirect url
      end
    end
  end
end
