# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2016_12_12_000511) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "matchups", id: :serial, force: :cascade do |t|
    t.integer "week_id"
    t.datetime "game_time", precision: nil
    t.integer "home_team_id"
    t.integer "away_team_id"
    t.boolean "completed"
    t.boolean "tie"
    t.integer "winning_team_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.boolean "locked"
  end

  create_table "nfl_teams", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "conference"
    t.string "division"
    t.string "color"
    t.string "abbreviation"
    t.string "home_field"
    t.string "website"
    t.integer "wins"
    t.integer "losses"
    t.integer "ties"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "logo_file_name"
    t.string "logo_content_type"
    t.integer "logo_file_size"
    t.datetime "logo_updated_at", precision: nil
  end

  create_table "payments", id: :serial, force: :cascade do |t|
    t.integer "pool_entry_id"
    t.datetime "paid_at", precision: nil
    t.decimal "amount"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "picks", id: :serial, force: :cascade do |t|
    t.integer "pool_entry_id"
    t.integer "week_id"
    t.integer "team_id"
    t.boolean "locked_in"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.boolean "auto_picked"
    t.integer "matchup_id"
  end

  create_table "pool_entries", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "team_name"
    t.boolean "paid"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.boolean "knocked_out", default: false
    t.integer "knocked_out_week_id"
    t.integer "season_id"
  end

  create_table "seasons", id: :serial, force: :cascade do |t|
    t.integer "year"
    t.string "name"
    t.decimal "entry_fee"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.boolean "open_for_registration", default: false
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "favorite_team_id"
    t.string "phone"
    t.datetime "paid_at", precision: nil
    t.text "comments"
    t.string "cell"
    t.boolean "admin", default: false
    t.string "name"
    t.string "authentication_token"
    t.boolean "blocked", default: false
    t.index ["authentication_token"], name: "index_users_on_authentication_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "web_states", id: :serial, force: :cascade do |t|
    t.integer "week_id", null: false
    t.text "broadcast_message", default: "", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "season_id"
  end

  create_table "weeks", id: :serial, force: :cascade do |t|
    t.integer "season_id"
    t.integer "week_number"
    t.boolean "open_for_picks", default: true
    t.datetime "start_date", precision: nil
    t.datetime "end_date", precision: nil
    t.datetime "deadline", precision: nil
    t.integer "default_team_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.boolean "active_for_scoring", default: true
  end

end
