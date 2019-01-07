class CreateFolderDocuments < ActiveRecord::Migration[5.2]
  def change
    create_table :folder_documents do |t|
      t.references :folder, foreign_key: true, null: false
      t.references :document, index: { unique: true }, foreign_key: true, null: false

      t.timestamps
    end
  end
end
