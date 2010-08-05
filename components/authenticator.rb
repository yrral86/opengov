#!/usr/bin/env ruby1.9.1

dir = File.expand_path(File.dirname(__FILE__))

require dir + '/authenticator/m/usersession'
require dir + '/../lib/component'

class OpenGovAuthenticatorComponent < OpenGovComponent
  def require_models
    # this require has to be delayed until after initialize is called
    # because user's init requires activerecord to be activated
    require Config::RootDir + '/components/authenticator/m/user'
  end

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
      OpenGovView.render_string("logged in username: #{current_user.username}, <a href='/logout'>logout</a>")
    when 'newuser'
      create_user(env)
    when 'edituser'
      edit_user(env)
    end
  end

  def login(env)
    session_params = params['user_session']
    user_session = UserSession.new session_params
    if user_session.save
      login_success
    elsif session_params
      pam_params = {:pam_login => session_params['username'],
        :pam_password => session_params['password']}
      pam_session = UserSession.new(pam_params)
      if pam_session.save
        login_success
      else
        login_fail(pam_session)
      end
    else
      login_fail(user_session)
    end
  end

  def login_fail(user_session)
    OpenGovView.render_erb_from_file(view_file("newsession"),binding)
  end

  def login_success
      url = session[:onlogin]
      session[:onlogin] = nil
      url ||= "/home"
      OpenGovView.redirect url
  end

  def logout(env)
    session = current_session
    session.destroy if session
    OpenGovView.redirect "/login"
  end

  def create_user(env)
    user = User.new(params['user'])
    if user.save
      UserSession.create(user)
      OpenGovView.redirect '/home'
    else
      OpenGovView.render_erb_from_file(view_file('newuser'),binding)
    end
  end

  def update_user(env)
    user = current_user
    if user.update_attributes(params['user'])
      OpenGovView.redirect '/home'
    else
      OpenGovView.render_erb_from_file(view_file('edituser'),binding)
    end
  end

end

Daemons.run_proc('OpenGovAuthenticatorComponent',
                 {:dir_mode => :normal, :dir => dir}) do
  auth = OpenGovAuthenticatorComponent.new(
                                           'Authenticator',
                                           [UserSession],
                                           [],
                                           [])
  auth.require_models
  auth.add_models([User])
  auth.daemonize
end
