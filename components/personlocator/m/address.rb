dir = File.expand_path(File.dirname(__FILE__))

require dir + '/../../../lib/model'

class Address < OpenGovModel
  belongs_to :person
end
