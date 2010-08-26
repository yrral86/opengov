require 'authlogic'
require 'authlogic_pam'

class User < Derailed::Model
  include AuthlogicPam::ActsAsAuthentic
  acts_as_authentic

  def username
    pam_login || super
  end
end
