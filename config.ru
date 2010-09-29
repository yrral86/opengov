dir = File.expand_path(File.dirname(__FILE__))
$:.unshift "#{dir}/lib"
require 'derailed/rack_app'

use Rack::Session::Cookie
use Derailed::RackApp::Middleware
use Rack::ContentType
run Derailed::RackApp::RequestRouter.new
