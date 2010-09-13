require 'rack/test'
require 'webrat'

require 'derailed/testcase'

Webrat.configure do |config|
  config.mode = :rack
# this will work with webrat from git, but there hasn't been a release yet
#  config.mode = :selenium
#  config.application_framework = :rack
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
