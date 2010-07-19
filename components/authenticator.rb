#!/usr/bin/env ruby1.9.1

dir = File.expand_path(File.dirname(__FILE__))

require dir + '/../lib/component'
#require dir + '/authenticator/m/user'
#require dir + '/authenticator/m/address'

class OpenGovAuthenticatorComponent < OpenGovComponent
  def routes
    # /home is temporary
    ['login', 'logout','home']
  end

  def call(env)
    case env[:parser].path(1)
    when "login"
      login(env)
    when "logout"
      logout(env)
    when 'home'
      OpenGovView.render_string("logged in id: #{env['rack.session'][:userid].to_s}, <a href='/logout'>logout</a>")
    end
  end

  def login(env)
    if env[:parser].request.post?
      # if env[:session].login then      # saves token to db, set cookies
      env['rack.session'] = {
        :userid => 1,
        :token => 3
      }
      OpenGovView.redirect "/home"
    # elsif env['session'].authenticated? then
      # OpenGovView.redirect "/home"
    else
      OpenGovView.render_string("TODO: login form<form method='post'><input type='submit' value='login'></form>")
    end
  end
  
  def logout(env)
    # delete persistence token from db
    env['rack.session'] = {}
    OpenGovView.redirect "/login"
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
