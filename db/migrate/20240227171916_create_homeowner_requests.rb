class CreateHomeownerRequests < ActiveRecord::Migration[7.1]
  def change
    create_table :homeowner_requests do |t|
      t.text :description
      t.integer :homeowner_id
      #t.references :homeowner, null: false, foreign_key: true

      t.timestamps
    end
  end
end