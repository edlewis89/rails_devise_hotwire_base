class CreateServiceResponses < ActiveRecord::Migration[7.1]
  def change
    create_table :service_responses do |t|
      t.references :contractor, foreign_key: { to_table: :users }, null: false # Assuming `user_id` is the foreign key for `User`
      t.references :service_request, null: false, foreign_key: true
      t.text :message
      t.decimal :proposed_cost, precision: 10, scale: 2  # Adjust precision and scale as per your needs
      t.datetime :estimated_completion_date
      t.integer :status, null: false, default: 0

      t.timestamps
    end
    # Add index on contractor_id for better query performance
    # add_index :service_responses, :contractor_id
    # Add index on status for better query performance
    add_index :service_responses, [:status, :service_request_id]
  end
end
