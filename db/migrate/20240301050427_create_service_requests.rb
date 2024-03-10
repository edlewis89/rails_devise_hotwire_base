class CreateServiceRequests < ActiveRecord::Migration[7.1]
  def change
    create_table :service_requests do |t|
      t.references :homeowner, polymorphic: true, null: false, index: true
      t.references :service, foreign_key: true
      t.string :title
      t.string :image
      t.text :description
      t.string :location
      t.decimal :budget, precision: 10, scale: 2  # Adjust precision and scale as per your needs
      t.string :timeline
      t.string :status, default: "pending"
      t.boolean :private, default: 0

      t.timestamps
    end
    # Add index on homeowner_id for better query performance
    # add_index :service_requests, :homeowner_id
    # Add index on status for better query performance
    add_index :service_requests, [:status, :service_id]
  end
end
