#!/usr/bin/env ruby1.8

require 'drb'
require 'lib/datacomponent.rb'
require 'model/person.rb'

class OpenGovPersonComponent < OpenGovDataComponent

end

OpenGovPersonComponent.new(Person)
