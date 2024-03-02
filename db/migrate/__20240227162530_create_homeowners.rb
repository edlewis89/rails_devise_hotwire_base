class CreateHomeowners < ActiveRecord::Migration[7.1]
  def change
    create_table :homeowners do |t|
      t.references :user, null: true, foreign_key: true, index: true
      t.references :profile, null: true, foreign_key: true, index: true

      # Add other columns specific to the homeowner model here
      # Add the verified attribute
      # t.boolean :verified, default: false

      t.timestamps
    end
  end
end

