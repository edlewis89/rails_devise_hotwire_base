class CreateServiceResponses < ActiveRecord::Migration[7.1]
  def change
    create_table :service_responses do |t|
      t.references :contractor, polymorphic: true, null: false, index: true
      t.references :service_request, foreign_key: true
      t.text :message
      t.decimal :proposed_cost, precision: 10, scale: 2  # Adjust precision and scale as per your needs
      t.datetime :estimated_completion_date
      t.string :status, default: "pending"

      t.timestamps
    end
    # Add index on contractor_id for better query performance
    # add_index :service_responses, :contractor_id
    # Add index on status for better query performance
    add_index :service_responses, [:status, :service_request_id]
  end
end
