require 'authlogic'
require 'authlogic_pam'
require 'drb'

dir = File.expand_path(File.dirname(__FILE__))

class UserSession < Authlogic::Session::Base
  include DRbUndumped
end
