class AddSchemaToForm < ActiveRecord::Migration[5.2]
  def change
    add_column :forms, :schema, :jsonb
  end
end
