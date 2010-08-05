require 'requestrouter'
require 'lib/controller'

use Rack::Session::Cookie
use OpenGovController
run OpenGovRequestRouter.new
