#!/usr/bin/env ruby

dir = File.expand_path(File.dirname(__FILE__))
require dir + '/../../lib/derailed/daemon'

class OpenGovStaticComponent < Derailed::Component::Base

end

Derailed::Daemon.component('Static').daemonize(OpenGovStaticComponent)
