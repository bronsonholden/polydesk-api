class ApplicationPolicy
  attr_reader :user, :record

  def initialize(auth, record)
    @account_user = AccountUser.find_by user_id: auth.user.id, account_id: auth.account.id
    raise Pundit::NotAuthorizedError unless @account_user
    @record = record
  end

  def index?
    false if @account_user.nil?
  end

  def show?
    false if @account_user.nil?
  end

  def create?
    false if @account_user.nil?
  end

  def new?
    create?
  end

  def update?
    false if @account_user.nil?
  end

  def edit?
    update?
  end

  def destroy?
    false if @account_user.nil?
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
end
