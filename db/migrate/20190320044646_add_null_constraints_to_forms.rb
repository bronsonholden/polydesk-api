class AddNullConstraintsToForms < ActiveRecord::Migration[5.2]
  def change
    change_column_null :forms, :schema, false
    change_column_null :forms, :layout, false
  end
end
