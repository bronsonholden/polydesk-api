class SetDocumentDefaultFolderIdAndRemoveIndex < ActiveRecord::Migration[5.2]
  def change
    remove_index :documents, :folder_id
    change_column_default :documents, :folder_id, 0

    documents = Document.all
    documents.each do |document|
      if document.folder_id.nil?
        document.folder_id = 0
        document.save!
      end
    end
  end
end
