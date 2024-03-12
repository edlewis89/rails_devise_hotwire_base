class CreateContractorServices < ActiveRecord::Migration[7.1]
  def change
    create_table :contractor_services do |t|
      t.references :user, foreign_key: true
      t.references :service, foreign_key: true
      t.timestamps
    end
  end
end
