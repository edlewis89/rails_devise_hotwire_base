class CreateReviews < ActiveRecord::Migration[7.1]
  def change
    create_table :reviews do |t|
      t.text :content
      t.integer :rating
      t.references :homeowner, null: false, foreign_key: { to_table: :users }
      t.references :contractor, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
