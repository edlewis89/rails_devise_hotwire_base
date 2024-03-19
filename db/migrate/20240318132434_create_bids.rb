class CreateBids < ActiveRecord::Migration[7.1]
  def change
    create_table :bids do |t|
      t.references :contractor, null: false, foreign_key: { to_table: :users }
      t.references :service_request, null: false, foreign_key: true
      t.decimal :proposed_price, precision: 10, scale: 2, null: false
      t.integer :estimated_timeline_in_days
      t.text :additional_fees
      t.text :terms_and_conditions
      t.text :description
      t.text :message, null: false
      t.string :communication_preferences, null: false
      t.text :validity_period
      t.integer :status, null: false, default: 0

      t.timestamps
    end
    add_index :bids, :status
  end
end
