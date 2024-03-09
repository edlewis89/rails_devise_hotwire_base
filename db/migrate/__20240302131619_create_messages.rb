class CreateMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :messages do |t|
      t.references :sender, foreign_key: { to_table: :users }
      t.references :recipient, foreign_key: { to_table: :users }
      t.string :subject
      t.text :body
      t.boolean :read, default: false

      t.timestamps
    end

    add_index :messages, :sender_id unless index_exists?(:messages, :sender_id)
    add_index :messages, :recipient_id unless index_exists?(:messages, :recipient_id)
  end
end
