class AddTimestampsToPrefabs < ActiveRecord::Migration[5.2]
  def change
    add_timestamps :prefabs, null: true, default: -> { 'NOW()' }
    change_column_default :prefabs, :created_at, nil
    change_column_default :prefabs, :updated_at, nil
  end
end
