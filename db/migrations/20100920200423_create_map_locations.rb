class CreateMapLocations < ActiveRecord::Migration
  def self.up
    create_table :map_locations do |t|
      t.references :map
      t.references :location
    end
  end

  def self.down
    drop_table :map_locations
  end
end
