#!/usr/bin/env ruby1.8

# hackish... required to daemonize... need better solution before deployment
$: << '/home/larry/Projects/opengov/'
require 'lib/datacomponent.rb'
require 'model/address.rb'

class OpenGovAddressComponent < OpenGovDataComponent

end

OpenGovAddressComponent.new(Address)
