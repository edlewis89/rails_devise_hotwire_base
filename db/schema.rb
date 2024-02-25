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

ActiveRecord::Schema[7.1].define(version: 2024_02_24_000534) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "contractors", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "email"
    t.string "phone_number"
    t.string "city"
    t.string "state"
    t.string "zipcode"
    t.string "website"
    t.boolean "have_insurance", default: false
    t.boolean "have_license", default: false
    t.string "license_number"
    t.string "insurance_provider"
    t.string "insurance_policy_number"
    t.string "service_area"
    t.integer "years_of_experience", default: 0
    t.string "specializations", default: [], array: true
    t.string "certifications", default: [], array: true
    t.string "languages_spoken", default: [], array: true
    t.decimal "hourly_rate", precision: 8, scale: 2, default: "0.0"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_contractors_on_active"
    t.index ["city"], name: "index_contractors_on_city"
    t.index ["email"], name: "index_contractors_on_email", unique: true
    t.index ["have_insurance"], name: "index_contractors_on_have_insurance"
    t.index ["have_license"], name: "index_contractors_on_have_license"
    t.index ["name"], name: "index_contractors_on_name"
    t.index ["phone_number"], name: "index_contractors_on_phone_number"
    t.index ["state"], name: "index_contractors_on_state"
    t.index ["zipcode"], name: "index_contractors_on_zipcode"
  end

  create_table "homeowners", force: :cascade do |t|
    t.string "name"
    t.text "description"
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
