class AddLayoutToForm < ActiveRecord::Migration[5.2]
  def change
    add_column :forms, :layout, :jsonb, default: {}
  end
end
