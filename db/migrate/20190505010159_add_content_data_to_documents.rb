class AddContentDataToDocuments < ActiveRecord::Migration[5.2]
  def change
    add_column :documents, :content_data, :text
  end
end
