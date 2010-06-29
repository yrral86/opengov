require 'lib/model'

class Person < OpenGovModel
  has_many :addresses

  validates_presence_of :lname
end
