class AddContentAttributesToDocument < ActiveRecord::Migration[5.2]
  def change
    add_column :documents, :file_size, :integer
    add_column :documents, :content_type, :string
  end
end
