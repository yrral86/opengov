#!/usr/bin/env ruby1.9.1

require 'authlogic'

dir = File.expand_path(File.dirname(__FILE__))

require dir + '/../lib/component'
require dir + '/authenticator/m/user'
require dir + '/authenticator/m/usersession'

class OpenGovAuthenticatorComponent < OpenGovComponent
  def routes
    # /home is temporary
    ['login', 'logout', 'home', 'newuser', 'edituser']
  end

  def call(env)
    Authlogic::Session::Base.controller = env[:parser]
    case env[:parser].path(1)
    when "login"
      login(env)
    when "logout"
      logout(env)
    when 'home'
      OpenGovView.render_string("logged in id: #{current_user.id}, <a href='/logout'>logout</a>")
    when 'newuser'
      create_user(env)
    when 'edituser'
      edit_user(env)
    end
  end

  def login(env)
    user_session = UserSession.new(env[:parser].params[:user_session])
    if user_session.save
      OpenGovView.redirect "/home"
    else
      OpenGovView.render_erb_from_file(view_file("newsession"),binding)
    end
  end
  
  def logout(env)
    session = UserSession.find
    session.destroy if session
    OpenGovView.redirect "/login"
  end

  def current_user
    s = UserSession.find
    s && s.record
  end

  def create_user(env)
    puts env[:parser].params['user']
    puts 'before user.new'
#    begin
      user = User.new(env[:parser].params['user'])
 #   rescue
  #    puts 'in rescue'
   # end
    puts 'before user.save'
    if user.save
      puts 'user.save succeeded'
      OpenGovView.redirect '/home'
    else
      puts user.errors.full_messages
      OpenGovView.render_erb_from_file(view_file('newuser'),binding)
    end
  end

  def update_user(env)
    user = current_user
    if user.update_attributes(env[:parser].params['user'])
      OpenGovView.redirect '/home'
    else
      OpenGovView.render_erb_from_file(view_file('edituser'),binding)
    end
  end

end

Daemons.run_proc('OpenGovAuthenticatorComponent',
                 {:dir_mode => :normal, :dir => dir}) do
  OpenGovAuthenticatorComponent.new(
                                    'Authenticator',
                                    [],
                                    [],
                                    []
                                    ).daemonize
end
