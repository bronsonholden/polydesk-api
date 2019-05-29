# This migration is part of a change to enforce unique folder names.
# The default value of 0 for parent_id will let us add a unique index on
# the name and parent_id columns to guarantee unique folder names at
# each level of the folder structure.
class AddNullConstraintToFoldersParent < ActiveRecord::Migration[5.2]
  def change
    change_column_null :folders, :parent_id, false
    change_column_default :folders, :parent_id, 0
  end
end
