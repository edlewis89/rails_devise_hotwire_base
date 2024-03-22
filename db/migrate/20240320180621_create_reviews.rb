class CreateReviews < ActiveRecord::Migration[7.1]
  def change
    create_table :reviews do |t|
      t.string :title
      t.text :content
      t.integer :rating
      t.date :date
      t.string :reviewer_name
      t.string :reviewer_email
      t.boolean :visibility, default: true
      t.integer :likes, default: 0
      t.integer :dislikes, default: 0
      t.string :tags, array: true, default: []
      t.references :homeowner, null: false, foreign_key: { to_table: :users }
      t.references :contractor, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
