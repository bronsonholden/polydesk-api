class ApplicationPolicy
  attr_reader :user, :record

  def initialize(auth, record)
    @account_user = AccountUser.find_by user_id: auth.user.id, account_id: auth.account.id
    raise Pundit::NotAuthorizedError unless @account_user
    @record = record
  end

  def index?
    false if @account_user.nil? || @account_user.disabled?
  end

  def show?
    false if @account_user.nil? || @account_user.disabled?
  end

  def create?
    false if @account_user.nil? || @account_user.disabled?
  end

  def new?
    create?
  end

  def update?
    false if @account_user.nil? || @account_user.disabled?
  end

  def edit?
    update?
  end

  def destroy?
    false if @account_user.nil? || @account_user.disabled?
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
