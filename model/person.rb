require 'rubygems'
require 'active_record'

class Person < ActiveRecord::Base
  include DRbUndumped
end
