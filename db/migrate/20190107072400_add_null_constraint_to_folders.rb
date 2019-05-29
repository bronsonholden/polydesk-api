class AddNullConstraintToFolders < ActiveRecord::Migration[5.2]
  def change
    change_column_null :folders, :name, false
  end
end
