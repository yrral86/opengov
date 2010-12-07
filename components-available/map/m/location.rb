class Location < Derailed::Component::Model
  has_many :map_locations
  has_many :maps, :through => :map_locations

  def formatted_address
    f_address = "#{address} #{city}, #{state} #{zip}"
    f_address == " ,  " ? nil : f_address
  end

  def coords
    "#{latitude} #{longitude}"
  end
end
