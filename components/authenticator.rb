#!/usr/bin/env ruby1.9.1

dir = File.expand_path(File.dirname(__FILE__))
require dir + '/../lib/derailed/daemon'

class OpenGovAuthenticatorComponent < Derailed::Component::Authenticator

end

component = Derailed::Daemon.component('Authenticator')
component.daemonize(OpenGovAuthenticatorComponent)
