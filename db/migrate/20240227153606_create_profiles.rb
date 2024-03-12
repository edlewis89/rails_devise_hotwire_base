class CreateProfiles < ActiveRecord::Migration[7.1]
  def change
    create_table :profiles do |t|
      t.references :user, foreign_key: true
      t.references :profileable, polymorphic: true, null: false, index: true
      t.decimal :hourly_rate, precision: 8, scale: 2, default: 0.00
      t.integer :years_of_experience, default: 0
      t.boolean :availability, default: false
      t.boolean :have_insurance, default: false
      t.boolean :have_license, default: false
      t.string :name,               null: false, default: ""
      t.string :phone_number,       null: false, default: ""
      # Add a column to hold the image metadata
      t.string :image_data
      t.string :website
      t.string :license_number
      t.string :insurance_provider
      t.string :insurance_policy_number
      t.string :service_area
      t.string :specializations, array: true, default: []
      t.string :certifications, array: true, default: []
      t.string :languages_spoken, array: true, default: []
      t.text :description

      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
    end

    # This migration will create a unique index on the license_number column only for
    # non-NULL values, allowing multiple records to have NULL license numbers
    # while still enforcing uniqueness for non-NULL values.
    #add_index :profiles, :homeowner_id
    #add_index :profiles, :contractor_id
    add_index :profiles, :name
    add_index :profiles, :phone_number
  end
end
