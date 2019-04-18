class DropFolderDocuments < ActiveRecord::Migration[5.2]
  def change
    drop_table :folder_documents
  end
end
