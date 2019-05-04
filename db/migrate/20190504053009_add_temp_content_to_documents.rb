class AddTempContentToDocuments < ActiveRecord::Migration[5.2]
  def change
    add_column :documents, :content_tmp, :string
  end
end
