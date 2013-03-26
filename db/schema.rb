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

ActiveRecord::Schema.define(:version => 20130326071851) do

  create_table "mediaset_photos", :force => true do |t|
    t.integer  "photo_id"
    t.integer  "mediaset_id"
    t.integer  "order"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "mediaset_photos", ["mediaset_id"], :name => "index_mediaset_photos_on_mediaset_id"
  add_index "mediaset_photos", ["photo_id"], :name => "index_mediaset_photos_on_photo_id"

  create_table "mediasets", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "persona_id"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.integer  "up_votes",    :default => 0,     :null => false
    t.integer  "down_votes",  :default => 0,     :null => false
    t.boolean  "featured",    :default => false, :null => false
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
    t.integer  "up_votes",               :default => 0,  :null => false
    t.integer  "down_votes",             :default => 0,  :null => false
    t.string   "avatar"
  end

  add_index "personas", ["email"], :name => "index_personas_on_email", :unique => true
  add_index "personas", ["reset_password_token"], :name => "index_personas_on_reset_password_token", :unique => true

  create_table "photos", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "persona_id"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.string   "avatar"
    t.boolean  "featured"
    t.integer  "up_votes",    :default => 0, :null => false
    t.integer  "down_votes",  :default => 0, :null => false
  end

  add_index "photos", ["persona_id"], :name => "index_photos_on_persona_id"

  create_table "trackers", :force => true do |t|
    t.integer  "persona_id"
    t.string   "tracked_object_type"
    t.integer  "tracked_object_id"
    t.string   "relationship"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  add_index "trackers", ["persona_id"], :name => "index_trackers_on_persona_id"

  create_table "votings", :force => true do |t|
    t.string   "voteable_type"
    t.integer  "voteable_id"
    t.string   "voter_type"
    t.integer  "voter_id"
    t.boolean  "up_vote",       :null => false
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "votings", ["voteable_type", "voteable_id", "voter_type", "voter_id"], :name => "unique_voters", :unique => true
  add_index "votings", ["voteable_type", "voteable_id"], :name => "index_votings_on_voteable_type_and_voteable_id"
  add_index "votings", ["voter_type", "voter_id"], :name => "index_votings_on_voter_type_and_voter_id"

end
