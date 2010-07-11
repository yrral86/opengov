class OpenGovRequestAuthenticator
  def initialize(env)
    @env = env
  end

  def authenticate
    false
  end

  def authenticated?
    true
  end
end
