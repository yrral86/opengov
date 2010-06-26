1#!/usr/bin/env ruby1.8

# hackish... required to daemonize... need better solution before deployment
$: << '/home/larry/Projects/opengov/'
require 'lib/datacomponent'
require 'model/person'
require 'model/address'

class OpenGovPersonLocatorComponent < OpenGovDataComponent

end

OpenGovPersonLocatorComponent.new('PersonLocator',Person,Address)
