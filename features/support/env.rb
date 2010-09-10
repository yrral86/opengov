require 'rack/test'
require 'webrat'

require 'derailed/testcase'

Webrat.configure do |config|
  config.mode = :rack
end

class OpenGovWorld < Derailed::TestCase
  include Webrat::Methods
  include Webrat::Matchers

  Webrat::Methods.delegate_to_session :response_code, :response_body
end

World do
  w = OpenGovWorld.new("Cucumber")
  w.setup
  w
end
