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

ActiveRecord::Schema.define(:version => 20131002151042) do

  create_table "carts", :force => true do |t|
    t.string   "item_type"
    t.string   "item_sku"
    t.integer  "item_id"
    t.integer  "persona_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "carts", ["persona_id"], :name => "index_carts_on_persona_id"

  create_table "coupons", :force => true do |t|
    t.string   "code"
    t.integer  "persona_id"
    t.date     "redeem_date"
    t.date     "expire_date"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "sku_id"
  end

  add_index "coupons", ["sku_id"], :name => "index_coupons_on_sku_id"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "followers", :force => true do |t|
    t.integer  "persona_id"
    t.string   "tracked_object_type"
    t.integer  "tracked_object_id"
    t.string   "relationship"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  add_index "followers", ["persona_id"], :name => "index_trackers_on_persona_id"

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
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.integer  "up_votes",       :default => 0,     :null => false
    t.integer  "down_votes",     :default => 0,     :null => false
    t.boolean  "featured",       :default => false, :null => false
    t.boolean  "system_visible", :default => true
  end

  add_index "mediasets", ["persona_id"], :name => "index_mediasets_on_persona_id"

  create_table "personas", :force => true do |t|
    t.string   "realname"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.string   "screen_name"
    t.integer  "up_votes",               :default => 0,     :null => false
    t.integer  "down_votes",             :default => 0,     :null => false
    t.string   "avatar"
    t.string   "email",                  :default => "",    :null => false
    t.string   "encrypted_password",     :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.boolean  "agreeToTNC"
    t.boolean  "premium",                :default => false, :null => false
    t.date     "premiumSince"
    t.date     "premiumExpire"
  end

  add_index "personas", ["email"], :name => "index_personas_on_email", :unique => true
  add_index "personas", ["reset_password_token"], :name => "index_personas_on_reset_password_token", :unique => true

  create_table "photos", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "persona_id"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.string   "avatar"
    t.boolean  "featured",       :default => false, :null => false
    t.integer  "up_votes",       :default => 0,     :null => false
    t.integer  "down_votes",     :default => 0,     :null => false
    t.boolean  "visible",        :default => true,  :null => false
    t.boolean  "system_visible", :default => false
    t.datetime "taken_at"
    t.string   "md5"
  end

  add_index "photos", ["persona_id"], :name => "index_photos_on_persona_id"

  create_table "skus", :force => true do |t|
    t.string   "code"
    t.string   "model"
    t.string   "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       :limit => 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "versions", :force => true do |t|
    t.string   "item_type",      :null => false
    t.integer  "item_id",        :null => false
    t.string   "event",          :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.text     "object_changes"
  end

  add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"

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
