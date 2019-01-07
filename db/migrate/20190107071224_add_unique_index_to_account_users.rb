class AddUniqueIndexToAccountUsers < ActiveRecord::Migration[5.2]
  def change
    add_index :account_users, [:account_id, :user_id], unique: true
  end
end
