#!/usr/bin/env ruby

require 'derailed/testcase'

class OpenGovAuthenticatorTest < Derailed::TestCase
  def setup
    super(false)
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
    get '/home'
    assert_equal 200, last_response.status
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
    user_model = Derailed::Service.get_model('Authenticator::User')
    user_model.find_by_username('testuser').destroy
  end

  def test_logout
    do_auth
    get '/home'
    assert_equal 200, last_response.status
    get '/logout'
    get '/home'
    assert_equal 302, last_response.status
  end

  def test_not_logged_in
    get '/home'
    assert_equal 302, last_response.status
    follow_redirects
    assert_equal '/login', last_request.path
  end

  def test_authentication_before_notfound
    get '/invalidurl'
    assert_equal 302, last_response.status
    follow_redirects
    assert_equal '/login', last_request.path
  end

  def test_pam_login
    do_auth({'user_session'=>{'username'=> `whoami`.chomp,'password'=>`cat .password`.chomp}})
    get '/home'
    assert_equal 200, last_response.status, "PAM login failed, make sure the file .password contains your current login password"
  end
end
