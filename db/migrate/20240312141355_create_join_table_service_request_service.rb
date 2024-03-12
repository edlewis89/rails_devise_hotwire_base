class CreateJoinTableServiceRequestService < ActiveRecord::Migration[7.1]
  def change
    create_join_table :service_requests, :services do |t|
      # Optionally, you can add any additional columns here
      # For example:
      # t.integer :quantity, default: 1
      # t.boolean :urgent, default: false
    end
  end
end
