#!/usr/bin/env ruby1.9.1

dir = File.expand_path(File.dirname(__FILE__))

require dir + '/../lib/component'
#require dir + '/authenticator/m/user'

class OpenGovAuthenticatorComponent < OpenGovComponent

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
