dir = File.expand_path(File.dirname(__FILE__))
$:.unshift "#{dir}/lib"
require 'derailed/rack'

use Rack::Session::Cookie
use Derailed::Controller::Middleware
run Derailed::RequestRouter.new
