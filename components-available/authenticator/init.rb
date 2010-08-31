#!/usr/bin/env ruby

dir = File.expand_path(File.dirname(__FILE__))
require dir + '/../../lib/derailed/daemon'

class OpenGovAuthenticatorComponent < Derailed::Component::Authenticator

end

component = Derailed::Daemon.component('Authenticator')
component.daemonize(OpenGovAuthenticatorComponent)
