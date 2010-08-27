require 'lib/derailed'

use Rack::Session::Cookie
use Derailed::Controller::Middleware
run Derailed::RequestRouter.new
