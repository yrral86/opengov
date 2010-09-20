class Location < Derailed::Component::Model
  has_many :map_locations
  has_many :maps, :through => :map_locations
end
