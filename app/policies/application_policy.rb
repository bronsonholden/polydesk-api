class ApplicationPolicy
  attr_reader :user, :record

  def initialize(auth, record)
    @account_user = AccountUser.find_by user_id: auth.user.id, account_id: auth.account.id
    raise Polydesk::ApiExceptions::UserException::NoAccountAccess.new(auth.user) unless @account_user
    raise Polydesk::ApiExceptions::AccountIsDisabled.new(auth.account) if auth.account.discarded?
    @record = record
  end

  def default_policy
    false if @account_user.nil? || @account_user.disabled?
  end

  def index?
    default_policy
  end

  def show?
    default_policy
  end

  def create?
    default_policy
  end

  def new?
    create?
  end

  def update?
    default_policy
  end

  def edit?
    update?
  end

  def destroy?
    default_policy
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope.all
    end
  end

  protected
    def has_permission(code)
      !!@account_user.permissions.find_by(code: code)
    end
end
