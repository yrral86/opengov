require 'authlogic'
require 'authlogic_pam'

dir = File.expand_path(File.dirname(__FILE__))

require dir + '/../../../lib/model'

class User < OpenGovModel
  include AuthlogicPam::ActsAsAuthentic
  acts_as_authentic
end
