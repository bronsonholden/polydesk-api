class UserPolicy < ApplicationPolicy
  def initialize(auth, user)
  end

  def create?
    true
  end
end
