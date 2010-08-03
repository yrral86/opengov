#!/usr/bin/env ruby1.9.1

require 'lib/testcase'

class OpenGovRequestRouterTest < OpenGovTestCase
  def test_personlist
    get '/personlocator/person'
    assert_equal 200, last_response.status
  end

  def test_invalid_person_id
    get '/personlocator/person/bogusid'
    assert_equal 404, last_response.status
  end
end
