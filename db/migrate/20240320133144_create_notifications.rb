class CreateNotifications < ActiveRecord::Migration[7.1]
  def change
    create_table "notifications", force: :cascade do |t|
      t.bigint "recipient_id", null: false
      t.bigint "sender_id"
      t.text "message"
      t.integer "notification_type"
      t.boolean "read_status", default: false
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false

      t.index ["recipient_id"], name: "index_notifications_on_recipient_id"
      t.index ["sender_id"], name: "index_notifications_on_sender_id"
    end
  end
end
