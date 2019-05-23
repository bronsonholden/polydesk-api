class MoveAccountInfoToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :account_name, :string, null: false
    add_column :users, :account_identifier, :string, null: false
    add_index :users, :account_identifier, unique: true
  end
end
