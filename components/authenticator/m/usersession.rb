dir = File.expand_path(File.dirname(__FILE__))

require 'authlogic'

class UserSession < Authlogic::Session::Base
end
