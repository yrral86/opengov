class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
      t.string :subject
      t.string :message
      t.integer :to_id
      t.integer :from_id
      t.boolean :read, :default => false

      t.timestamps
    end

    add_index :messages, :to_id
  end

  def self.down
    drop_table :messages
  end
end
