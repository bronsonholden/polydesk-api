class AccountPolicy < ApplicationPolicy
  class Scope
    attr_reader :auth, :scope

    def initialize(auth, scope)
      @auth = auth
      @scope = scope
    end

    def resolve
      # TODO: Polydesk admins can see all accounts
      # return scope.all if auth.user.email ...
      auth.user.accounts
    end
  end

  def index?
    true
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
