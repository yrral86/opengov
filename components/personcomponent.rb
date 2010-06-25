#!/usr/bin/env ruby1.8

# hackish... required to daemonize... need better solution before deployment
$: << '/home/larry/Projects/opengov/'
require 'lib/datacomponent.rb'
require 'model/person.rb'

class OpenGovPersonComponent < OpenGovDataComponent

end

OpenGovPersonComponent.new(Person)
