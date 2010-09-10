dir = File.expand_path(File.dirname(__FILE__))
libraries = "#{dir}/lib"
require 'derailed'

use Rack::Session::Cookie
use Derailed::Controller::Middleware
run Derailed::RequestRouter.new
