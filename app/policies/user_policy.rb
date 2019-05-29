class UserPolicy < ApplicationPolicy
  attr_reader :user, :user_subject

  def initialize(auth, user_subject)
    super
    @user_subject = user_subject
  end

  def show?
    true
  end

  def update?
    allowed = super
    return allowed unless allowed.nil?
    has_permission(:user_update)
  end

  def destroy?
    default_policy
  end

  def restore?
    default_policy
  end

  # Only applies when authenticated, i.e. creating a user for an invitee to
  # an existing account.
  def allowed_attributes_for_create
    [:name, :email, :password, :password_confirmation]
  end

  def allowed_attributes_for_update
    [:name, :password]
  end

  def allowed_relationships_for_create
    []
  end

  def allowed_relationships_for_update
    []
  end
end
