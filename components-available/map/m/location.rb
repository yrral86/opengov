class Location < Derailed::Component::Model
  has_many :map_locations
  has_many :maps, :through => :map_locations

  def self.from_attribs(attribs)
    location = Location.find_or_create_by_title attribs['title']
    # if we have an existing location, but the latitude and longitude don't
    # match, create a new location
    if location.latitude && (location.latitude != attribs['latitude'] ||
                              location.longitude != attribs['longitude'])
      location = Location.create attribs
    # otherwise, same title and coordinates, update any other details
    # that may have been updated
    else
      location.update_attributes attribs
    end
    location
  end
end
