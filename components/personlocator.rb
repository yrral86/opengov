#!/usr/bin/env ruby1.9.1

dir = File.dirname(__FILE__)

require dir + '/../lib/component'
require dir + '/personlocator/m/person'
require dir + '/personlocator/m/address'

class OpenGovPersonLocatorComponent < OpenGovComponent

end

Daemons.run_proc('OpenGovPersonLocatorComponent') do
  OpenGovPersonLocatorComponent.new(
                                    'PersonLocator',
                                    [Person, Address],
                                    [],
                                    ['Static']
                                    ).daemonize
end
