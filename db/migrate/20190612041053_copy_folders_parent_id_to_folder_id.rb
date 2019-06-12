class CopyFoldersParentIdToFolderId < ActiveRecord::Migration[5.2]
  def change
    Folder.all.each { |folder|
      folder.folder_id = folder.parent_id
      folder.save!
    }
  end
end
