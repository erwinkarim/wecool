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

ActiveRecord::Schema.define(:version => 20130204043334) do

  create_table "mediasets", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "persona_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "mediasets", ["persona_id"], :name => "index_mediasets_on_persona_id"

  create_table "personas", :force => true do |t|
    t.string   "realname"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "screen_name"
  end

  add_index "personas", ["email"], :name => "index_personas_on_email", :unique => true
  add_index "personas", ["reset_password_token"], :name => "index_personas_on_reset_password_token", :unique => true

  create_table "photos", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "persona_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "avatar"
  end

  add_index "photos", ["persona_id"], :name => "index_photos_on_persona_id"

end
