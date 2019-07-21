class ChangeFormSchemaToJson < ActiveRecord::Migration[5.2]
  def up
    change_column :forms, :schema, 'text USING CAST(schema AS text)'
    change_column :form_submissions, :schema_snapshot, 'text USING CAST(schema_snapshot AS text)'
  end

  def down
    change_column :forms, :schema, 'jsonb USING CAST(schema AS jsonb)'
    change_column :form_submissions, :schema_snapshot, 'jsonb USING CAST(schema_snapshot AS jsonb)'
  end
end
