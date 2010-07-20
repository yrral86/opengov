class OpenGovSession
  def initialize(env)
    @env = env
  end

  def login
    # should check users table for login credentials
    if true then
      userid = 1 # pull from record
      token = generate_token
      # save token to db
      @env['rack.session'] = {
        :userid => userid,
        :token => token
      }
      true
    else
      false
    end    
  end

  def authenticated?
    @env['rack.session'][:userid] == 1 &&
      @env['rack.session'][:token] == generate_token
  end

  def generate_token
    3
#    rand(2**(0.size *8))
  end
end
