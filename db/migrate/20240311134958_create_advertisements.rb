class CreateAdvertisements < ActiveRecord::Migration[7.1]
  def change
    create_table :advertisements do |t|
      t.string :title
      t.string :url
      # Add a column to hold the image metadata
      t.string :image_data
      t.string :link
      t.integer :placement, default: 2
      t.integer :advertisement_type, default: 0
      t.references :service, foreign_key: true

      t.timestamps
    end
  end
end
