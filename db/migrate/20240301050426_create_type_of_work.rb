class CreateTypeOfWork < ActiveRecord::Migration[7.1]
  def change
    create_table :type_of_works do |t|
      t.string :name

      t.timestamps
    end
  end
end
