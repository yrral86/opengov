class CreateLocations < ActiveRecord::Migration
  def self.up
    create_table :locations do |t|
      t.string :title
      t.text :description
      t.string :address
      t.string :city
      t.string :state
      t.string :zip
      t.decimal :latitude, :precision => 10, :scale => 8
      t.decimal :longitude, :precision => 10, :scale => 7
      t.boolean :mobile, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :locations
  end
end
