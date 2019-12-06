class BlueprintPolicy < ApplicationPolicy
  attr_reader :user, :blueprint

  def initialize(auth, blueprint)
    super
    @blueprint = blueprint
  end

  def create?
    true
  end

  def allowed_attributes_for_create
    [:name, :namespace, :schema, :view]
  end

  def allowed_attributes_for_update
    [:name, :schema, :view]
  end

  def allowed_relationships_for_create
    []
  end

  def allowed_relationships_for_update
    []
  end
end
