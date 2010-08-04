class AddPamLoginToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :pam_login, :string
  end

  def self.down
    remove_column :users, :pam_login
  end
end
