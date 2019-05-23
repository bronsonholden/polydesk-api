class ApplicationPolicy
  attr_reader :user, :record

  def initialize(auth, record)
    verify_user
  end

  def verify_user(auth, record)
    @account = User.find_by!(identifier: auth.identifier)
    @account_user = AccountUser.find_by user_id: auth.user.id, account_id: @account.id
    raise Polydesk::ApiExceptions::UserException::NoAccountAccess.new(auth.user) unless @account_user
    @record = record
  end

  def default_policy
    return false if @account_user.nil? || @account_user.disabled?
    return true if @account_user.role == 'administrator'
  end

  def index?
    default_policy
  end

  def show?
    default_policy
  end

  def create?
    return false if @account_user.role == 'guest'
    default_policy
  end

  def new?
    create?
  end

  def update?
    return false if @account_user.role == 'guest'
    default_policy
  end

  def edit?
    update?
  end

  def destroy?
    return false if @account_user.role == 'guest'
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
