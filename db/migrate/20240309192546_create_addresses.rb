class CreateAddresses < ActiveRecord::Migration[7.1]
  def change
    create_table :addresses do |t|
      t.string :street
      t.string :city
      t.string :state
      t.string :zipcode
      t.string :country
      t.float :latitude
      t.float :longitude
      t.text :additional_info
      t.references :addressable, polymorphic: true, null: true

      t.timestamps
    end
    add_index :addresses, [:addressable_id, :addressable_type]
    add_index :addresses, :city
    add_index :addresses, :state
    add_index :addresses, :zipcode
    add_index :addresses, :latitude
    add_index :addresses, :longitude
  end
end
