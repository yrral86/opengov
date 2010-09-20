class CreateMaps < ActiveRecord::Migration
  def self.up
    create_table :maps do |t|
      t.references :user
      t.decimal :center_latitude, :precision => 10, :scale => 8,
      :default => 39.987
      t.decimal :center_longitude, :precision => 10, :scale => 7,
      :default => -80.7319
      t.integer :scale, :default => 4

      t.timestamps
    end
  end

  def self.down
    drop_table :maps
  end
end
