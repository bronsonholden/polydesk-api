class AddUniqueFieldsToForms < ActiveRecord::Migration[5.2]
  def change
    add_column :forms, :unique_fields, :string, array: true
  end
end
