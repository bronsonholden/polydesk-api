class AddDefaultAccountToUser < ActiveRecord::Migration[5.2]
  def change
    add_reference :users, :default_account, foreign_key: { to_table: :accounts }
  end
end
