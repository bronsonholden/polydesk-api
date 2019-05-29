class CreateOptions < ActiveRecord::Migration[5.2]
  def change
    create_table :options do |t|
      t.integer :name, index: { unique: true }, null: false
      t.string :value, null: false

      t.timestamps
    end
  end
end
