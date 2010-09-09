#!/usr/bin/env ruby

dir = File.expand_path(File.dirname(__FILE__))
require dir + '/../lib/derailed/testcase'

class OpenGovStaticTest < Derailed::TestCase::Unit
  def test_javascript
    get '/static/javascript/prototype.js'
    string1 = last_response.body
    string2 = File.read('javascript/prototype.js')
    assert_equal string1, string2
  end
end
