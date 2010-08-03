#!/usr/bin/env ruby1.9.1

require 'lib/testcase'
require 'lib/componenthelper'

class OpenGovAuthenticatorTest < OpenGovTestCase
  def setup
    super(false)
    @ch = OpenGovComponentHelper.new
  end

  def test_getlogin
    get '/login'
    assert last_response.ok?
  end

  def test_getnewuser
    do_auth
    get '/newuser'
    assert last_response.ok?
  end

  def test_login
    do_auth
  end

  def test_create_and_login
    do_auth
    user = {'username' => 'testuser',
      'password' => 'insecurepassword',
      'password_confirmation' => 'insecurepassword'}
    post '/newuser', {'user' => user}
    assert_equal 302, last_response.status,"Create user failed"
    assert_equal '/home', last_response.headers["Location"],"Create user failed"
    follow_redirects
    assert_equal 200, last_response.status
    assert_equal '/home', last_request.path
    do_auth({'user_session' => user})
    follow_redirects
    assert last_response.ok?, "Login as new user failed"
    @ch.get_model("Authenticator::user").find_by_username('testuser').destroy
  end

  def test_logout
    do_auth
    get '/logout'
    get '/home'
    assert_equal 302, last_response.status
  end
end
