require 'authlogic'

dir = File.expand_path(File.dirname(__FILE__))

require dir + '/../../../lib/model'

class User < OpenGovModel
  acts_as_authentic
#  validates_presence_of :username
end
