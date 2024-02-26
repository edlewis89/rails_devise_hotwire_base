class CreateContractors < ActiveRecord::Migration[6.0]
  def change
    create_table :contractors do |t|
      t.decimal :hourly_rate, precision: 8, scale: 2, default: 0.00
      t.boolean :active, default: false
      t.string :name
      t.text :description
      t.string :email
      t.string :phone_number
      t.string :city
      t.string :state
      t.string :zipcode
      t.string :image
      t.string :website
      t.boolean :have_insurance, default: false
      t.boolean :have_license, default: false
      t.string :license_number
      t.string :insurance_provider
      t.string :insurance_policy_number
      t.string :service_area
      t.integer :years_of_experience, default: 0
      t.string :specializations, array: true, default: []
      t.string :certifications, array: true, default: []
      t.string :languages_spoken, array: true, default: []

      t.timestamps
    end

    # This migration will create a unique index on the license_number column only for
    # non-NULL values, allowing multiple records to have NULL license numbers
    # while still enforcing uniqueness for non-NULL values.
    add_index :contractors, :email, unique: true
    add_index :contractors, :name
    add_index :contractors, :phone_number
    add_index :contractors, :city
    add_index :contractors, :state
    add_index :contractors, :zipcode
    add_index :contractors, :have_insurance
    add_index :contractors, :have_license
    add_index :contractors, :active
  end
end
