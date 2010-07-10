dir = File.expand_path(File.dirname(__FILE__))

require 'authlogic'

require dir + '/../../../lib/model'

class User < OpenGovModel
  acts_as_authentic
end
