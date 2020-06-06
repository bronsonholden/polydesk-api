class CreateAccountUserGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :account_user_groups do |t|
      t.bigint :account_user_id
      t.references :group, foreign_key: true
      t.timestamps
    end

    add_index :account_user_groups, [:account_user_id, :group_id], unique: true
  end
end
