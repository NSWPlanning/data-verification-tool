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

ActiveRecord::Schema.define(:version => 20120815033833) do

  create_table "land_and_property_information_import_logs", :force => true do |t|
    t.string   "filename"
    t.integer  "user_id"
    t.integer  "processed",   :default => 0
    t.integer  "created",     :default => 0
    t.integer  "updated",     :default => 0
    t.integer  "error_count", :default => 0
    t.boolean  "finished",    :default => false
    t.boolean  "success",     :default => false
    t.datetime "finished_at"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  add_index "land_and_property_information_import_logs", ["user_id"], :name => "index_land_and_property_information_import_logs_on_user_id"

  create_table "land_and_property_information_records", :force => true do |t|
    t.string   "cadastre_id",                            :null => false
    t.string   "lot_number"
    t.string   "section_number"
    t.string   "plan_label"
    t.string   "title_reference",                        :null => false
    t.string   "lga_name",                               :null => false
    t.string   "start_date"
    t.string   "end_date"
    t.string   "modified_date"
    t.string   "last_update"
    t.string   "md5sum",                   :limit => 32, :null => false
    t.integer  "local_government_area_id"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "land_and_property_information_records", ["cadastre_id", "local_government_area_id"], :name => "lpi_cadastre_id_lga_id", :unique => true

  create_table "local_government_areas", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "alias"
  end

  create_table "local_government_areas_users", :id => false, :force => true do |t|
    t.integer "local_government_area_id"
    t.integer "user_id"
  end

  add_index "local_government_areas_users", ["local_government_area_id", "user_id"], :name => "index_lgas_users"

  create_table "users", :force => true do |t|
    t.string   "email",                           :null => false
    t.string   "crypted_password"
    t.string   "salt"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.integer  "roles"
    t.string   "reset_password_token"
    t.datetime "reset_password_token_expires_at"
    t.datetime "reset_password_email_sent_at"
    t.string   "name"
  end

  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token"

  create_table "versions", :force => true do |t|
    t.string   "item_type",  :null => false
    t.integer  "item_id",    :null => false
    t.string   "event",      :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"

end
