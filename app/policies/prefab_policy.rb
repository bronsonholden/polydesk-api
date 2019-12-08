class PrefabPolicy < ApplicationPolicy
  attr_reader :user, :prefab

  def initialize(auth, prefab)
    super
    @prefab = prefab
  end

  def create?
    true
  end

  def index?
    true
  end

  def show?
    true
  end

  def allowed_attributes_for_create
    [:namespace, :schema, :view, :data]
  end

  def allowed_attributes_for_update
    [:schema, :view, :data]
  end

  def allowed_relationships_for_create
    [:blueprint]
  end

  def allowed_relationships_for_update
    []
  end
end
