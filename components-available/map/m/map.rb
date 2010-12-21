class Map < Derailed::Component::Model
  has_many :map_locations
  has_many :locations, :through => :map_locations

  def remove_location(id)
    MapLocation.find(:first, :conditions => {:location_id => id,
                       :map_id => self.id}).delete
  end

  def add_location(attribs)
    location = Location.from_attribs attribs
    self.locations << location
  end

  def self.from_user(id)
    self.find_or_create_by_user_id id
  end
end
