#!/usr/bin/env ruby1.9.1

dir = File.expand_path(File.dirname(__FILE__))

require dir + '/../lib/derailed'
require dir + '/personlocator/m/person'
require dir + '/personlocator/m/address'

class OpenGovPersonLocatorComponent < Derailed::Component::Base

end

Daemons.run_proc('OpenGovPersonLocatorComponent',
                 {:dir_mode => :normal, :dir => dir}) do
  OpenGovPersonLocatorComponent.new(
                                    'PersonLocator',
                                    [Person, Address],
                                    [],
                                    ['Static']
                                    ).daemonize
end
