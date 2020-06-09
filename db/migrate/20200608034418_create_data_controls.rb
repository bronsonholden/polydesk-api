class CreateDataControls < ActiveRecord::Migration[5.2]
  def change
    create_table :data_controls do |t|
      t.references :group, foreign_key: true
      t.string :key, null: false
      t.jsonb :value, null: false
      t.string :operator, null: false
      t.string :namespace, null: false
      t.integer :mode, limit: 1
      t.timestamps
    end

    add_index :data_controls, [:group_id, :namespace, :key, :value, :operator, :mode], unique: true, name: :index_data_controls
  end
end
