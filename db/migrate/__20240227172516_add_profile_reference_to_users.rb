class AddProfileReferenceToUsers < ActiveRecord::Migration[7.1]
  def change
    # add_reference :users, :profile, foreign_key: true
    # add_index :users, :profile_id
  end
end
