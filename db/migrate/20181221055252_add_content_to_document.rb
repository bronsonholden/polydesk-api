class AddContentToDocument < ActiveRecord::Migration[5.2]
  def up
    add_column :documents, :content, :string
  end

  def down
    remove_column :documents, :content
  end
end
