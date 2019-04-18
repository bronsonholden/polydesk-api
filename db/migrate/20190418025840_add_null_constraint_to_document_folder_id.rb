class AddNullConstraintToDocumentFolderId < ActiveRecord::Migration[5.2]
  def change
    change_column_null :documents, :folder_id, false
  end
end
