class CreateServiceRequests < ActiveRecord::Migration[7.1]
  def change
    create_table :service_requests do |t|
      t.references :homeowner, foreign_key: { to_table: :users }, null: false
      t.string :title
      t.string :image_data
      t.text :description
      t.string :location
      t.integer :zipcode_radius, default: 15
      t.integer :status, null: false, default: 0
      t.decimal :budget, precision: 10, scale: 2 # Adjust precision and scale as per your needs
      t.datetime :due_date
      t.string :timeline
      t.boolean :active, default: 0
      t.boolean :private, default: 0

      t.timestamps
    end
    # Add index on homeowner_id for better query performance
    # add_index :service_requests, :homeowner_id
    # Add index on status for better query performance

    add_index :service_requests, :status
  end
end
