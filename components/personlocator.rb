#!/usr/bin/env ruby1.9.1

dir = File.expand_path(File.dirname(__FILE__))
require dir + '/../lib/derailed/daemon'

class OpenGovPersonLocatorComponent < Derailed::Component::Base

end

component = Derailed::Daemon.component('PersonLocator')
component.daemonize(OpenGovPersonLocatorComponent,['Static'])

