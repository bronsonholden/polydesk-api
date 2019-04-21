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
    false
  end

  def destroy?
    false
  end

  def restore?
    false
  end
end
