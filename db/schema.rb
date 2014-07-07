# encoding: UTF-8
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

ActiveRecord::Schema.define(:version => 20140703183741) do

  create_table "options", :id => false, :force => true do |t|
    t.integer  "id",                :limit => 8,                               :null => false
    t.integer  "vehicle_id",                                                   :null => false
    t.text     "description"
    t.string   "opt_code"
    t.boolean  "is_quick_package"
    t.boolean  "is_option_package"
    t.boolean  "is_dio_option"
    t.decimal  "msrp",                           :precision => 9, :scale => 2
    t.decimal  "invoice",                        :precision => 9, :scale => 2
    t.string   "opt_kind"
    t.datetime "created_at",                                                   :null => false
    t.datetime "updated_at",                                                   :null => false
  end

  add_index "options", ["vehicle_id"], :name => "index_options_on_vehicle_id"

  create_table "prices", :id => false, :force => true do |t|
    t.integer  "id",         :limit => 8,                               :null => false
    t.integer  "vehicle_id",                                            :null => false
    t.decimal  "price",                   :precision => 8, :scale => 2
    t.datetime "created_at",                                            :null => false
    t.datetime "updated_at",                                            :null => false
  end

  add_index "prices", ["vehicle_id"], :name => "index_prices_on_vehicle_id"

  create_table "shard_seq_tbl", :primary_key => "nextval", :force => true do |t|
  end

  create_table "users", :id => false, :force => true do |t|
    t.integer  "id",               :limit => 8,   :null => false
    t.string   "name"
    t.string   "email"
    t.string   "crypted_password", :limit => 128
    t.string   "phone",            :limit => 20
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.integer  "sharded_id",       :limit => 8
  end

  create_table "vehicles", :id => false, :force => true do |t|
    t.integer  "id",             :limit => 8,                                  :null => false
    t.integer  "user_id",                                                      :null => false
    t.integer  "year"
    t.string   "make",           :limit => 100
    t.string   "model",          :limit => 100
    t.string   "trim",           :limit => 100
    t.string   "interior_color", :limit => 100
    t.string   "exterior_color", :limit => 100
    t.decimal  "sticker_price",                 :precision => 10, :scale => 2
    t.datetime "created_at",                                                   :null => false
    t.datetime "updated_at",                                                   :null => false
  end

  add_index "vehicles", ["user_id"], :name => "index_vehicles_on_user_id"

end
