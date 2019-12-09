class AddViewToBlueprints < ActiveRecord::Migration[5.2]
  def change
    add_column :blueprints, :view, :json
  end
end
