require 'rubygems'
require 'active_record'
require 'drb'

class OpenGovModel < ActiveRecord::Base
  self.abstract_class = true
  include DRbUndumped
end
