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

ActiveRecord::Schema[7.0].define(version: 2023_07_20_082602) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "bubble_uploads", force: :cascade do |t|
    t.integer "tier", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "main_page_bubbles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

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
    t.string "name", limit: 255
    t.string "conference", limit: 255
    t.string "division", limit: 255
    t.string "color", limit: 255
    t.string "abbreviation", limit: 255
    t.string "home_field", limit: 255
    t.string "website", limit: 255
    t.integer "wins"
    t.integer "losses"
    t.integer "ties"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
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
    t.string "team_name", limit: 255
    t.boolean "paid"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.boolean "knocked_out", default: false
    t.integer "knocked_out_week_id"
    t.integer "season_id"
  end

  create_table "seasons", id: :serial, force: :cascade do |t|
    t.integer "year"
    t.string "name", limit: 255
    t.decimal "entry_fee"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.boolean "open_for_registration", default: false
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", limit: 255, default: "", null: false
    t.string "encrypted_password", limit: 255, default: "", null: false
    t.string "reset_password_token", limit: 255
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.string "current_sign_in_ip", limit: 255
    t.string "last_sign_in_ip", limit: 255
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "favorite_team_id"
    t.string "phone", limit: 255
    t.datetime "paid_at", precision: nil
    t.text "comments"
    t.string "cell", limit: 255
    t.boolean "admin", default: false
    t.string "name", limit: 255
    t.string "authentication_token", limit: 255
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

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
end
