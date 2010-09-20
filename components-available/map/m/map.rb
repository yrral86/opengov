class Map < Derailed::Component::Model
  has_many :map_locations
  has_many :locations, :through => :map_locations
end
