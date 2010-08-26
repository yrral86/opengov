require 'authlogic'
require 'authlogic_pam'

dir = File.expand_path(File.dirname(__FILE__))

require dir + '/../../../lib/derailed/model'

class User < Derailed::Model
  include AuthlogicPam::ActsAsAuthentic
  acts_as_authentic

  def username
    pam_login || super
  end
end
