class Person < Derailed::Component::Model
  has_many :addresses
  validates_presence_of :lname

  def abstract_map
    {
      :the_firstest_name => :fname
    }
  end
end
