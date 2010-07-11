require 'requestrouter'
require 'authlogic'

require 'lib/requestauthenticator'

@adapter = OpenGovRequestAuthenticator.new(OpenGovAuthenticatorProxy.new)
puts 'before'
AuthLogic::Session::Base.controller = @adapter
puts 'after'
app = OpenGovRequestRouter.new
run app
