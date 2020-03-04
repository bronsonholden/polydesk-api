class CreateGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :groups do |t|
      t.string :name, index: { unique: true }, null: false
      t.timestamps
    end
  end
end
