#!/usr/bin/env ruby1.9.1

dir = File.expand_path(File.dirname(__FILE__))

require dir + '/../lib/component'
require dir + '/authenticator/m/user'
require dir + '/authenticator/m/usersession'

class OpenGovSessionsComponent < OpenGovComponent
  def current_session
    UserSession.find    
  end

  def current_user
    current_session.user
  end

  def create(env)
    r = Rack::Request.new(env)
    @user_session = UserSession.new(r.params[:user_session])
  end

  def destroy(env)
    current_user_session.destroy
    # TODO: redirect_to new_user_session_url
  end
end

Daemons.run_proc('OpenGovSessionsComponent',
                 {:dir_mode => :normal, :dir => dir}) do
  OpenGovSessionsComponent.new(
                               'Sessions',
                               [User,UserSession],
                               [],
                               []
                               ).daemonize
end
