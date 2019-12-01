class CreateBlueprints < ActiveRecord::Migration[5.2]
  def up
    create_table :blueprints do |t|
      t.string :name, index: { unique: true }, null: false
      t.string :namespace, index: { unique: true }, null: false
      t.json :schema, null: false

      t.timestamps
    end
  end

  def down
    drop_table :blueprints
  end
end
