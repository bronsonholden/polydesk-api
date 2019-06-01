class AccountPolicy < ApplicationPolicy
  def initialize(auth, account)
    super
  end

  def create?
    true
  end

  def show?
    true
  end

  def update?
    allowed = super
    return allowed unless allowed.nil?
    has_permission?(:account_update)
  end

  def destroy?
    default_policy
  end

  def restore?
    default_policy
  end

  def allowed_attributes_for_create
    [:name, :identifier]
  end

  def allowed_attributes_for_update
    [:name]
  end

  def allowed_relationships_for_create
    []
  end

  def allowed_relationships_for_update
    []
  end
end
