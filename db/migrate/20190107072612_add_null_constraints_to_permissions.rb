class AddNullConstraintsToPermissions < ActiveRecord::Migration[5.2]
  def change
    change_column_null :permissions, :code, false
    change_column_null :permissions, :account_user_id, false
  end
end
