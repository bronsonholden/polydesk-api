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
    default_policy
  end

  def destroy?
    default_policy
  end

  def restore?
    default_policy
  end
end
