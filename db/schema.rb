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

ActiveRecord::Schema[7.1].define(version: 2024_03_20_180621) do
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

  create_table "addresses", force: :cascade do |t|
    t.string "street"
    t.string "city"
    t.string "state"
    t.string "zipcode"
    t.string "country"
    t.float "latitude"
    t.float "longitude"
    t.text "additional_info"
    t.string "addressable_type"
    t.bigint "addressable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["addressable_id", "addressable_type"], name: "index_addresses_on_addressable_id_and_addressable_type"
    t.index ["addressable_type", "addressable_id"], name: "index_addresses_on_addressable"
    t.index ["city"], name: "index_addresses_on_city"
    t.index ["latitude"], name: "index_addresses_on_latitude"
    t.index ["longitude"], name: "index_addresses_on_longitude"
    t.index ["state"], name: "index_addresses_on_state"
    t.index ["zipcode"], name: "index_addresses_on_zipcode"
  end

  create_table "advertisements", force: :cascade do |t|
    t.string "title"
    t.string "url"
    t.string "image_data"
    t.string "link"
    t.bigint "service_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["service_id"], name: "index_advertisements_on_service_id"
  end

  create_table "bids", force: :cascade do |t|
    t.bigint "contractor_id", null: false
    t.bigint "service_request_id", null: false
    t.decimal "proposed_price", precision: 10, scale: 2, null: false
    t.integer "estimated_timeline_in_days"
    t.text "additional_fees"
    t.text "terms_and_conditions"
    t.text "description"
    t.text "message", null: false
    t.string "communication_preferences", null: false
    t.text "validity_period"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contractor_id"], name: "index_bids_on_contractor_id"
    t.index ["service_request_id"], name: "index_bids_on_service_request_id"
    t.index ["status"], name: "index_bids_on_status"
  end

  create_table "contractor_homeowner_requests", force: :cascade do |t|
    t.bigint "homeowner_request_id", null: false
    t.integer "status", default: 0, null: false
    t.integer "contractor_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["homeowner_request_id"], name: "index_contractor_homeowner_requests_on_homeowner_request_id"
  end

  create_table "contractor_services", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "service_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["service_id"], name: "index_contractor_services_on_service_id"
    t.index ["user_id"], name: "index_contractor_services_on_user_id"
  end

  create_table "conversations", force: :cascade do |t|
    t.bigint "sender_id"
    t.bigint "recipient_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recipient_id"], name: "index_conversations_on_recipient_id"
    t.index ["sender_id"], name: "index_conversations_on_sender_id"
  end

  create_table "homeowner_requests", force: :cascade do |t|
    t.text "description"
    t.integer "homeowner_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "conversation_id"
    t.bigint "user_id"
    t.string "subject"
    t.text "body"
    t.boolean "read", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "recipient_id", null: false
    t.bigint "sender_id"
    t.text "message"
    t.integer "notification_type"
    t.boolean "read_status", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recipient_id"], name: "index_notifications_on_recipient_id"
    t.index ["sender_id"], name: "index_notifications_on_sender_id"
  end

  create_table "profiles", force: :cascade do |t|
    t.bigint "user_id"
    t.decimal "hourly_rate", precision: 8, scale: 2, default: "0.0"
    t.integer "years_of_experience", default: 0
    t.boolean "availability", default: false
    t.boolean "have_insurance", default: false
    t.boolean "have_license", default: false
    t.string "name", default: "", null: false
    t.string "phone_number", default: "", null: false
    t.string "secure_id", default: "", null: false
    t.string "image_data"
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
    t.index ["name"], name: "index_profiles_on_name"
    t.index ["phone_number"], name: "index_profiles_on_phone_number"
    t.index ["user_id"], name: "index_profiles_on_user_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.string "title"
    t.text "content"
    t.integer "rating"
    t.date "date"
    t.string "reviewer_name"
    t.string "reviewer_email"
    t.boolean "visibility", default: true
    t.integer "likes", default: 0
    t.integer "dislikes", default: 0
    t.string "tags", default: [], array: true
    t.bigint "homeowner_id", null: false
    t.bigint "contractor_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contractor_id"], name: "index_reviews_on_contractor_id"
    t.index ["homeowner_id"], name: "index_reviews_on_homeowner_id"
  end

  create_table "service_requests", force: :cascade do |t|
    t.bigint "homeowner_id", null: false
    t.string "title"
    t.string "image_data"
    t.text "description"
    t.string "location"
    t.integer "range", default: 15
    t.integer "status", default: 0, null: false
    t.decimal "budget", precision: 10, scale: 2
    t.datetime "due_date"
    t.string "timeline"
    t.boolean "active", default: false
    t.boolean "private", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["homeowner_id"], name: "index_service_requests_on_homeowner_id"
    t.index ["status"], name: "index_service_requests_on_status"
  end

  create_table "service_requests_services", id: false, force: :cascade do |t|
    t.bigint "service_request_id", null: false
    t.bigint "service_id", null: false
  end

  create_table "service_responses", force: :cascade do |t|
    t.bigint "contractor_id", null: false
    t.bigint "service_request_id", null: false
    t.text "message"
    t.decimal "proposed_cost", precision: 10, scale: 2
    t.datetime "estimated_completion_date"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contractor_id"], name: "index_service_responses_on_contractor_id"
    t.index ["service_request_id"], name: "index_service_responses_on_service_request_id"
    t.index ["status", "service_request_id"], name: "index_service_responses_on_status_and_service_request_id"
  end

  create_table "services", force: :cascade do |t|
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
    t.datetime "last_seen_at"
    t.integer "role", default: 0, null: false
    t.integer "subscription_level", default: 0, null: false
    t.string "type"
    t.boolean "active", default: false
    t.boolean "public", default: true
    t.boolean "verified", default: false
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "unlock_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
    t.index ["subscription_level"], name: "index_users_on_subscription_level"
    t.index ["type"], name: "index_users_on_type"
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "advertisements", "services"
  add_foreign_key "bids", "service_requests"
  add_foreign_key "bids", "users", column: "contractor_id"
  add_foreign_key "contractor_homeowner_requests", "homeowner_requests"
  add_foreign_key "contractor_services", "services"
  add_foreign_key "contractor_services", "users"
  add_foreign_key "conversations", "users", column: "recipient_id"
  add_foreign_key "conversations", "users", column: "sender_id"
  add_foreign_key "profiles", "users"
  add_foreign_key "reviews", "users", column: "contractor_id"
  add_foreign_key "reviews", "users", column: "homeowner_id"
  add_foreign_key "service_requests", "users", column: "homeowner_id"
  add_foreign_key "service_responses", "service_requests"
  add_foreign_key "service_responses", "users", column: "contractor_id"
end
