dir = File.expand_path(File.dirname(__FILE__))

require dir + '/derailed/config'

require dir + '/derailed/componentclient'
require dir + '/derailed/datatype'
require dir + '/derailed/type/person.rb'
require dir + '/derailed/manager'
require dir + '/derailed/requestrouter'
require dir + '/derailed/socket'

require dir + '/derailed/component/base'
require dir + '/derailed/component/authenticator'
require dir + '/derailed/controller/middleware'
