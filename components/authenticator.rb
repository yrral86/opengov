#!/usr/bin/env ruby1.9.1

dir = File.expand_path(File.dirname(__FILE__))

require dir + '/authenticator/m/usersession'
require dir + '/../lib/derailed'

class OpenGovAuthenticatorComponent < Derailed::Component::Authenticator
  def require_models
    # this require has to be delayed until after initialize is called
    # because user's init requires activerecord to be activated
    require Derailed::Config::RootDir + '/components/authenticator/m/user'
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
