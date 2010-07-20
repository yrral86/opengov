require 'authlogic'

dir = File.expand_path(File.dirname(__FILE__))

class UserSession < Authlogic::Session::Base
end
