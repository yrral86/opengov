dir = File.expand_path(File.dirname(__FILE__))

require dir + '/derailed/config'

require dir + '/derailed/componentclient'
require dir + '/derailed/datatype'
require dir + '/derailed/type/person.rb'
require dir + '/derailed/manager/interface'
require dir + '/derailed/requestrouter'

require dir + '/derailed/component/base'
require dir + '/derailed/component/authenticator'
require dir + '/derailed/component/authenticatorcontroller'
require dir + '/derailed/controller/middleware'
