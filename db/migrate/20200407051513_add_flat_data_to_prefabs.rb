class AddFlatDataToPrefabs < ActiveRecord::Migration[5.2]
  def change
    add_column :prefabs, :flat_data, :jsonb
  end
end
