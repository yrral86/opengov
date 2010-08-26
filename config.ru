require 'lib/derailed'

use Rack::Session::Cookie
use Derailed::Controller::Base
run Derailed::RequestRouter.new
