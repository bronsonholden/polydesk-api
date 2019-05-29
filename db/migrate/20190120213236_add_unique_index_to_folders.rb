class AddUniqueIndexToFolders < ActiveRecord::Migration[5.2]
  def change
    add_index :folders, [:parent_id, :name], unique: true
  end
end
