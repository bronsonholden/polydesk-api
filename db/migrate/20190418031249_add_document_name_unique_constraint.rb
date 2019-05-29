class AddDocumentNameUniqueConstraint < ActiveRecord::Migration[5.2]
  def change
    add_column :documents, :unique_enforcer, :integer, limit: 1, default: 0
    add_index :documents, [:folder_id, :name, :unique_enforcer], unique: true
  end
end
