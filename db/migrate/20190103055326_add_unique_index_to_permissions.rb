class AddUniqueIndexToPermissions < ActiveRecord::Migration[5.2]
  def change
    add_index :permissions, [:code, :account_user_id], unique: true
  end
end
