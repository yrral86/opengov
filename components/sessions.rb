#!/usr/bin/env ruby1.9.1

dir = File.expand_path(File.dirname(__FILE__))

require 'authlogic'

require dir + '/../lib/component'
require dir + '/authenticator/m/user'
require dir + '/authenticator/m/usersession'


class OpenGovAuthAdapter < Authlogic::ControllerAdapters::AbstractAdapter
  def cookie_domain
    env['SERVER_NAME']
  end
end

class OpenGovAuthController
  def initialize(component)
    @component = component
  end

  def call(env)
    OpenGovView.not_found("Authenticator failed")
  end

  def create(env)
    r = Rack::Request.new(env)
    @user_session = UserSession.new(r.params[:user_session])
  end

  def destroy(env)
    current_user_session.destroy
    # TODO: redirect_to new_user_session_url
  end

  private
  def current_user_session
    return @current_user_session if defined?(current_user_session)
    @current_user_session = User.find
  end

  def current_user
    return @current_user if defined?(current_user)
    @current_user = current_user_session && current_user_session.user
  end
end

class OpenGovAuthenticatorComponent < OpenGovComponent
  def initialize
    @controller = OpenGovAuthController.new(self)
    @adapter = OpenGovAuthAdapter.new(@controller)
# possibly needs moved to router.ru
# grab @adapter over drb
    super
  end

  def call(env)
    @controller.call(env)
  end
end

Daemons.run_proc('OpenGovAuthenticatorComponent',
                 {:dir_mode => :normal, :dir => dir}) do
  OpenGovAuthenticatorComponent.new(
                                    'Authenticator',
                                    [User,UserSession],
                                    [],
                                    []
                                    ).daemonize
end
