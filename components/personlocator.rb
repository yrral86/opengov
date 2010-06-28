#!/usr/bin/env ruby1.8

require 'lib/component'
require 'components/personlocator/m/person'
require 'components/personlocator/m/address'

class OpenGovPersonLocatorComponent < OpenGovComponent

end

Daemons.run_proc('OpenGovPersonLocatorComponent') do
  OpenGovPersonLocatorComponent.new(
                                    'PersonLocator',
                                    [Person, Address],
                                    []
                                    ).daemonize
end
