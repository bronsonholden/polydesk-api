class UserPolicy < ApplicationPolicy
  def initialize(auth, user)
    # Using a bit of a hack to avoid authorization on the create action.
    # Might be a cleaner way to bypass authorization from the
    # jsonapi-authorization gem but still preserve it for cases where a user
    # is being added to an account.
    @_auth = auth
    @_user = user
  end

  def create?
    true
  end

  def new?
    create?
  end

  def index?
    verify_user(@_auth, @_user)
    super
  end

  def show?
    verify_user(@_auth, @_user)
    super
  end

  def destroy?
    verify_user(@_auth, @_user)
    super
  end

  def update?
    verify_user(@_auth, @_user)
    super
  end

  def edit?
    update?
  end
end
