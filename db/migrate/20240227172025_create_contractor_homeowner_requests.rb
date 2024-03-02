class CreateContractorHomeownerRequests < ActiveRecord::Migration[7.1]
  def change
    create_table :contractor_homeowner_requests do |t|
      #t.references :contractor, null: false, foreign_key: { to_table: :users }, index: true
      t.references :homeowner_request, null: false, foreign_key: { to_table: :homeowner_requests }, index: true
      t.integer :status, null: false, default: 0
      t.integer :contractor_id

      # Add other attributes as needed
      t.timestamps
    end
  end
end
