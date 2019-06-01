class ApplicationPolicy
  attr_reader :user, :record

  def initialize(auth, record)
    @user = auth.user
    @account = auth.account
    @account_user = AccountUser.find_by(user: @user, account: @account)
    @record = record
    # TODO
    # raise Polydesk::ApiExceptions::AccountIsDisabled.new(auth.account) if auth.account.discarded?
  end

  def has_role?(role)
    !@account_user.nil? && @account_user.role == role
  end

  def administrator?
    has_role?('administrator')
  end

  def guest?
    has_role?('guest')
  end

  def default_policy
    return false if @account_user.nil? || @account_user.disabled?
    return true if administrator?
  end

  def index?
    default_policy
  end

  def show?
    default_policy
  end

  def create?
    return false if guest?
    default_policy
  end

  def new?
    create?
  end

  def update?
    return false if guest?
    default_policy
  end

  def edit?
    update?
  end

  def destroy?
    return false if guest?
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

  def has_permission?(code)
    !@account_user.nil? && !!@account_user.permissions.find_by(code: code)
  end
end
