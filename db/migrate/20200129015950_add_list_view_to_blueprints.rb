class AddListViewToBlueprints < ActiveRecord::Migration[5.2]
  def change
    add_column :blueprints, :list_view, :json
  end
end
