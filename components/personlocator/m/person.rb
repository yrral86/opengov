dir = File.expand_path(File.dirname(__FILE__))

require dir + '/../../../lib/derailed/model'

class Person < Derailed::Model
  has_many :addresses
  validates_presence_of :lname

  def abstract_map
    {
      :the_firstest_name => :fname
    }
  end
end
