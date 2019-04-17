class AddDiscardedAtToFolders < ActiveRecord::Migration[5.2]
  def change
    add_column :folders, :discarded_at, :datetime
    add_index :folders, :discarded_at
  end
end
