#!/usr/bin/env ruby1.9.1

require 'lib/testcase'

class OpenGovAuthenticatorTest < OpenGovTestCase
  def test_getlogin
    get '/login'
    assert last_response.ok?
  end

  def test_getnewuser
    get '/newuser'
    assert last_response.ok?
  end
end
