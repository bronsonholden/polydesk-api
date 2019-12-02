class CreatePrefabs < ActiveRecord::Migration[5.2]
  def change
    create_table :prefabs do |t|
      t.references :blueprint, foreign_key: true, index: true
      t.string :namespace, null: false
      t.integer :tag, null: false
      t.json :schema, null: false
      t.json :view, null: false
      t.jsonb :data, null: false
    end

    add_index :prefabs, [:namespace, :tag], unique: true
  end
end
