class AddFolderIdToFolders < ActiveRecord::Migration[5.2]
  def change
    add_reference :folders, :folder, index: true, foreign_key: true
  end
end
