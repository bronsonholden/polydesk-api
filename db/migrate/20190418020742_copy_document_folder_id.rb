class CopyDocumentFolderId < ActiveRecord::Migration[5.2]
  def change
    documents = Document.all
    documents.each do |document|
      document.folder_id = document.parent_folder.id
      document.save!
    end
  end
end
