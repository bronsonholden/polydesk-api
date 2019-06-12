class DropFoldersParentId < ActiveRecord::Migration[5.2]
  def change
    remove_column :folders, :parent_id, :bigint
    add_index :folders, [:folder_id, :name, :unique_enforcer], unique: true
  end
end
