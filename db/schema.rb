# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110113171704) do

  create_table "addresses", :force => true do |t|
    t.string   "street_address"
    t.string   "apartment"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "locations", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.decimal  "latitude",    :precision => 10, :scale => 8
    t.decimal  "longitude",   :precision => 10, :scale => 7
    t.boolean  "mobile",                                     :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "locations", ["title"], :name => "index_locations_on_title"

  create_table "map_locations", :force => true do |t|
    t.integer "map_id"
    t.integer "location_id"
  end

  create_table "maps", :force => true do |t|
    t.integer  "user_id"
    t.decimal  "center_latitude",  :precision => 10, :scale => 8, :default => 39.987
    t.decimal  "center_longitude", :precision => 10, :scale => 7, :default => -80.7319
    t.integer  "scale",                                           :default => 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "messages", :force => true do |t|
    t.string   "subject"
    t.string   "message"
    t.integer  "to_id"
    t.integer  "from_id"
    t.boolean  "read",       :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "messages", ["to_id"], :name => "index_messages_on_to_id"

  create_table "people", :force => true do |t|
    t.string   "fname"
    t.string   "lname"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "pam_login"
  end

end
