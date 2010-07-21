dir = File.expand_path(File.dirname(__FILE__))

require dir + '/componenthelper'

class OpenGovAuthenticatorHelper
  def initialize(env)
    @env = env
    @ch = OpenGovComponentHelper.new
  end

  def logout
    puts 'before session.find.destroy'
    session.find.destroy
    puts 'after session.find.destroy'
  end

  def authenticated?
    session.find
  end

  def session
    return @session if defined?(@session)
    @session = @ch.get_model("Authenticator::usersession")
  end

  def current_user
    return @user if defined?(@user)
    @user = session && session.record
  end
end
