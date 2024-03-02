class CreateServiceRequests < ActiveRecord::Migration[7.1]
  def change
    create_table :service_requests do |t|
      t.references :user, polymorphic: true, index: true
      t.references :type_of_work, foreign_key: true

      t.text :description
      t.string :location
      t.decimal :budget
      t.string :timeline
      t.string :image

      t.timestamps
    end
  end
end
