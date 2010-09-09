require 'rack/test'
require 'webrat'

dir = File.expand_path(File.dirname(__FILE__))
require dir + '/../../lib/derailed/testcase'

Webrat.configure do |config|
  config.mode = :rack
end

module OpenGovWorld
  include Derailed::TestCase
  include Webrat::Methods
  include Webrat::Matchers

  Webrat::Methods.delegate_to_session :response_code, :response_body
end

World(OpenGovWorld)
