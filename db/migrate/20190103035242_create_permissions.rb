class CreatePermissions < ActiveRecord::Migration[5.2]
  def change
    create_table :permissions do |t|
      t.integer :code
      t.bigint :account_user_id

      t.timestamps
    end
  end
end
