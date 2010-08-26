dir = File.expand_path(File.dirname(__FILE__))

require dir + '/../../../lib/derailed/model'

class Address < Derailed::Model
  belongs_to :person
end
