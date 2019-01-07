class AddNullConstraintsToAccountUser < ActiveRecord::Migration[5.2]
  def change
    change_column_null :account_users, :account_id, false
    change_column_null :account_users, :user_id, false
  end
end
