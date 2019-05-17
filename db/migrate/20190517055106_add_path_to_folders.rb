class AddPathToFolders < ActiveRecord::Migration[5.2]
  def change
    add_column :folders, :path, :string, default: '/'
  end
end
