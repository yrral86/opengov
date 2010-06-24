require 'rubygems'
require 'active_record'
require 'drb'

class Person < ActiveRecord::Base
  include DRbUndumped
end
