class User < Derailed::Component::Model
  include AuthlogicPam::ActsAsAuthentic
  acts_as_authentic

  def username
    pam_login || super
  end
end
