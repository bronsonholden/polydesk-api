class AddRoleToAccountUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :account_users, :role, :integer, default: 0
  end
end
