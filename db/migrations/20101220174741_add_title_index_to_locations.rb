class AddTitleIndexToLocations < ActiveRecord::Migration
  def self.up
    add_index :locations, :title
  end

  def self.down
    remove_index :locations, :title
  end
end
