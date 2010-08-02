#!/usr/bin/env ruby1.9.1

require 'lib/testcase'

class OpenGovAuthenticatorTest < OpenGovTestCase
  def setup
    super

    `./components/authenticator.rb start`

    # give the authenticator component time to start
    socket_wait('opengov_Authenticator',1)
  end

  def teardown
    # kills all components
    `./components/authenticator.rb stop`
    super
  end

  def test_getlogin
    get '/login'
    assert last_response.ok?
  end

  def test_getnewuser
    get '/newuser'
    assert last_response.ok?
  end
end
