# Options are important internal settings that are not available to users
# to view or configure.
class OptionPolicy < ApplicationPolicy
  attr_reader :user, :option

  def initialize(auth, option)
    super
    @option = option
  end

  def create?
    false
  end

  def show?
    false
  end

  def index?
    false
  end

  def update?
    false
  end

  def destroy?
    false
  end
end
