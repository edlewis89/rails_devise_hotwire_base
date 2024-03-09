class CreateMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :messages do |t|
      t.references :conversation, index: true
      t.references :user, index: true
      t.string :subject
      t.text :body
      t.boolean :read, default: false

      t.timestamps
    end
  end
end
