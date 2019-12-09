class AddNullConstraintToBlueprintsView < ActiveRecord::Migration[5.2]
  def change
    blueprints = Blueprint.all
    blueprints.each do |blueprint|
      blueprint.view = {}
      blueprint.save!
    end
    change_column_null :blueprints, :view, false
  end
end
