class CreateAddresses < ActiveRecord::Migration
  def self.up
    create_table :addresses do |t|
      t.string :street_address
      t.string :apartment
      t.string :city
      t.string :state
      t.string :zip

      t.timestamps
    end
  end

  def self.down
    drop_table :addresses
  end
end
