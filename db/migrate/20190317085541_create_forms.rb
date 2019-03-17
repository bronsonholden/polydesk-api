class CreateForms < ActiveRecord::Migration[5.2]
  def change
    create_table :forms do |t|
      t.string :name, index: { unique: true }, null: false

      t.timestamps
    end
  end
end
