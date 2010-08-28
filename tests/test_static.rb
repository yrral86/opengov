#!/usr/bin/env ruby1.9.1

require 'lib/derailed/testcase'

class OpenGovStaticTest < Derailed::TestCase
  def test_javascript
    get '/javascript/prototype.js'
    string1 = last_response.body
    string2 = File.read('javascript/prototype.js')
    assert_equal string1, string2
  end
end
