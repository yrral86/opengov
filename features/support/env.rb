require 'rack/test'
require 'webrat'

dir = File.expand_path(File.dirname(__FILE__) + '/../../')
$:.unshift "#{dir}/lib"

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

  def assert_have_link_to(url)
    assert_have_selector "a[href=\"#{url}\"]"
  end

  def person_record_from_full_name(name)
    name = name.split
    model = @client.get_model('PersonLocator::Person')
    model.find_by_fname_and_lname(name[0], name[1])
  end

  def send_component_command(component, command)
    manager = Derailed::Service.get('Manager')
    @result = manager.component_command(component.downcase,command)
  end

  def debug(message)
    result = @result
    send_component_command('debug_message', message)
    @result = result
  end
end

World do
  w = OpenGovWorld.new("Cucumber")
  w.setup
  w
end
