class AccountPolicy < ApplicationPolicy
  attr_reader :user, :account

  def initialize(auth, account)
    super
    @account = account
  end

  def show?
    true
  end

  def update?
    allowed = super
    return allowed unless allowed.nil?
    has_permission(:account_update)
  end

  def destroy?
    default_policy
  end

  def restore?
    default_policy
  end

  def allowed_attributes_for_create
    [:account_name, :account_identifier, :name, :email, :password, :password_confirmation]
  end

  def allowed_attributes_for_update
    [:account_name, :name, :password]
  end

  def allowed_relationships_for_create
    []
  end

  def allowed_relationships_for_update
    []
  end
end
