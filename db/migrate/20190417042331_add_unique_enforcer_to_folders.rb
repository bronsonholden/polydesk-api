# Unique enforcer is included in the unique index that prevents duplicate
# Folder names. When the Folder is discarded, the unique enforcer is set
# to NULL to "deactivate" the unique constraint (in PostgreSQL, NULLs are
# not equal). Undiscarding the Folder will set the enforcer to 0, which will
# then violate the unique constraint if another Folder exists with the same
# parent and name. This technique will be applied to all objects that must
# have unique names. Should Polydesk ever migrate to a different database
# that does treat NULL as equal to itself, the unique enforcer columns can be
# changed to store the record's primary key when discarded, and zero when
# not, replicating the behavior (but using more disk space).
class AddUniqueEnforcerToFolders < ActiveRecord::Migration[5.2]
  def change
    remove_index :folders, [:parent_id, :name]
    add_column :folders, :unique_enforcer, :integer, limit: 1, default: 0
    add_index :folders, [:parent_id, :name, :unique_enforcer], unique: true
  end
end
