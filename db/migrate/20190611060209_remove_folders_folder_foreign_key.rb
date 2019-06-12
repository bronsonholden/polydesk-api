class RemoveFoldersFolderForeignKey < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key :folders, :folders
  end
end
