class AddConstructionViewToBlueprints < ActiveRecord::Migration[5.2]
  def change
    add_column :blueprints, :construction_view, :json
  end
end
