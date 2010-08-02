require 'test/unit'
require 'rack/test'

require 'requestrouter'
require 'lib/controller'

class OpenGovTestCase < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Rack::Builder.new {
      use Rack::Session::Cookie
      use OpenGovController
      run OpenGovRequestRouter.new
    }
  end

  def setup
    while Dir.entries('/tmp').detect {|f| f.match /^opengov/ } do
      sleep 0.05
    end

    `./componentmanager.rb start`

    # give the daemons time to start and register themselves
    socket_wait('opengov', 3)
  end

  def socket_wait(name, qty)
    waiting = true
    while waiting do
      sockets = Dir.entries('/tmp').find_all {|e| e.match /^#{name}/}
      if sockets.length == qty then
        waiting = false
      else
        sleep 0.05
      end
    end
  end

  def teardown
    # kills all components
    `./componentmanager.rb stop`
  end
end
