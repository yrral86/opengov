require 'authlogic'

class OpenGovRequestAuthenticator < Authlogic::ControllerAdapters::AbstractAdapter
  def initialize
  end

  def cookie_domain
    env['SERVER_NAME']
  end

  def authenticate
    false
  end

  def authenticated?
    true
  end
end
