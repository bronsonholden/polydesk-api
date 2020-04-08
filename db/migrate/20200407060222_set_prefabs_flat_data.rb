class SetPrefabsFlatData < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    prefabs = Prefab.all.where(flat_data: nil)
    prefabs.each do |prefab|
      prefab.flat_data = Smush.smush(prefab.data)
      prefab.save!
    end
  end
end
