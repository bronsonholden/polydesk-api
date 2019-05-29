class AddFolderIdToDocuments < ActiveRecord::Migration[5.2]
  def change
    add_reference :documents, :folder, index: true
  end
end
