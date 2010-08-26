require 'lib/derailed'
require 'lib/controller'

use Rack::Session::Cookie
use OpenGovController
run Derailed::RequestRouter.new
