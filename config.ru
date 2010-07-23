require 'requestrouter'
require 'lib/controller'

app = OpenGovRequestRouter.new
use Rack::Session::Cookie
use OpenGovController
run app
