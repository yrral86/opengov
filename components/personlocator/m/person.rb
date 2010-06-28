require 'lib/model'

class Person < OpenGovModel
  has_many :addresses
end
