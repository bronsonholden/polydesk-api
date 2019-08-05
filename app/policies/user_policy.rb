class UserPolicy < ApplicationPolicy
  attr_reader :user, :user_subject

  class Scope
    attr_reader :auth, :scope

    def initialize(auth, scope)
      @auth = auth
      @scope = scope
    end

    def resolve
      if auth.account.nil?
        if auth.user.email.ends_with?("@polydesk.io")
          scope.all
        else
          scope.none
        end
      else
        scope.includes(:account_users).where(account_users: { account_id: auth.account.id })
      end
    end
  end

  def initialize(auth, user_subject)
    super
    @user_subject = user_subject
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
    has_permission?(:user_update)
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
    [:first_name, :last_name, :email, :password, :password_confirmation]
  end

  def allowed_attributes_for_update
    [:first_name, :last_name, :password]
  end

  def allowed_relationships_for_create
    []
  end

  def allowed_relationships_for_update
    []
  end
end
