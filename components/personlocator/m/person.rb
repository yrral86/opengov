class Person < Derailed::Component::Model
  has_many :addresses
  validates_presence_of :lname

  def abstract_map
    {
      :first_name => :fname,
      :last_name => :lname
    }
  end

  def self.type
    'Person'
  end
end
