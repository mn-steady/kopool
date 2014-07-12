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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140710040759) do

  create_table "matchups", force: true do |t|
    t.integer  "week_id"
    t.datetime "game_time"
    t.integer  "home_team_id"
    t.integer  "away_team_id"
    t.boolean  "completed"
    t.boolean  "tie"
    t.integer  "winning_team_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "nfl_teams", force: true do |t|
    t.string   "name"
    t.string   "conference"
    t.string   "division"
    t.string   "color"
    t.string   "abbreviation"
    t.string   "home_field"
    t.string   "website"
    t.integer  "wins"
    t.integer  "losses"
    t.integer  "ties"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
  end

  create_table "payments", force: true do |t|
    t.integer  "pool_entry_id"
    t.datetime "paid_at"
    t.decimal  "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "picks", force: true do |t|
    t.integer  "pool_entry_id"
    t.integer  "week_id"
    t.integer  "team_id"
    t.boolean  "locked_in"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "auto_picked"
    t.integer  "matchup_id"
  end

  create_table "pool_entries", force: true do |t|
    t.integer  "user_id"
    t.string   "team_name"
    t.boolean  "paid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "knocked_out", default: false
  end

  create_table "seasons", force: true do |t|
    t.integer  "year"
    t.string   "name"
    t.decimal  "entry_fee"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "open_for_registration", default: false
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "favorite_team_id"
    t.string   "phone"
    t.datetime "paid_at"
    t.text     "comments"
    t.string   "cell"
    t.boolean  "admin",                  default: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "web_states", force: true do |t|
    t.integer  "week_id",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "weeks", force: true do |t|
    t.integer  "season_id"
    t.integer  "week_number"
    t.boolean  "open_for_picks",     default: true
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "deadline"
    t.integer  "default_team_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active_for_scoring", default: true
    t.boolean  "current_week",       default: false
  end

end
