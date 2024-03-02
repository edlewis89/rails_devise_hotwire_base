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

ActiveRecord::Schema[7.1].define(version: 2024_03_01_050427) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "contractor_homeowner_requests", force: :cascade do |t|
    t.bigint "homeowner_request_id", null: false
    t.integer "status", default: 0, null: false
    t.integer "contractor_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["homeowner_request_id"], name: "index_contractor_homeowner_requests_on_homeowner_request_id"
  end

  create_table "homeowner_requests", force: :cascade do |t|
    t.text "description"
    t.integer "homeowner_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "profiles", force: :cascade do |t|
    t.bigint "user_id"
    t.string "profileable_type", null: false
    t.bigint "profileable_id", null: false
    t.decimal "hourly_rate", precision: 8, scale: 2, default: "0.0"
    t.integer "years_of_experience", default: 0
    t.boolean "availability", default: false
    t.boolean "have_insurance", default: false
    t.boolean "have_license", default: false
    t.string "name", default: "", null: false
    t.string "phone_number", default: "", null: false
    t.string "city"
    t.string "state"
    t.string "zipcode"
    t.string "image"
    t.string "website"
    t.string "license_number"
    t.string "insurance_provider"
    t.string "insurance_policy_number"
    t.string "service_area"
    t.string "specializations", default: [], array: true
    t.string "certifications", default: [], array: true
    t.string "languages_spoken", default: [], array: true
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["city"], name: "index_profiles_on_city"
    t.index ["name"], name: "index_profiles_on_name"
    t.index ["phone_number"], name: "index_profiles_on_phone_number"
    t.index ["profileable_type", "profileable_id"], name: "index_profiles_on_profileable"
    t.index ["state"], name: "index_profiles_on_state"
    t.index ["user_id"], name: "index_profiles_on_user_id"
    t.index ["zipcode"], name: "index_profiles_on_zipcode"
  end

  create_table "service_requests", force: :cascade do |t|
    t.string "user_type"
    t.bigint "user_id"
    t.bigint "type_of_work_id"
    t.text "description"
    t.string "location"
    t.decimal "budget"
    t.string "timeline"
    t.string "image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["type_of_work_id"], name: "index_service_requests_on_type_of_work_id"
    t.index ["user_type", "user_id"], name: "index_service_requests_on_user"
  end

  create_table "type_of_works", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "role", default: 0, null: false
    t.string "type"
    t.boolean "active", default: false
    t.boolean "public", default: true
    t.boolean "verified", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
    t.index ["type"], name: "index_users_on_type"
  end

  add_foreign_key "contractor_homeowner_requests", "homeowner_requests"
  add_foreign_key "profiles", "users"
  add_foreign_key "service_requests", "type_of_works"
end
