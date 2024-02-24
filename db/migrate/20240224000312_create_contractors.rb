class CreateContractors < ActiveRecord::Migration[7.1]
  def change
    create_table :contractors do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
