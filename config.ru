require 'requestrouter'

app = OpenGovRequestRouter.new
use Rack::Session::Cookie
run app
