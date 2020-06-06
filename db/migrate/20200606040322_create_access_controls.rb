class CreateAccessControls < ActiveRecord::Migration[5.2]
  def change
    create_table :access_controls do |t|
      t.references :group, foreign_key: true
      t.string :namespace, null: false
      t.integer :mode, limit: 1
      t.timestamps
    end

    add_index :access_controls, [:group_id, :namespace, :mode], unique: true
  end
end
