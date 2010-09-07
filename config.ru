dir = File.expand_path(File.dirname(__FILE__))

require dir + '/lib/derailed'

use Rack::Session::Cookie
use Derailed::Controller::Middleware
run Derailed::RequestRouter.new
