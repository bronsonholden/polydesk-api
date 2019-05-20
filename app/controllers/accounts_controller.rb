class AccountsController < ApplicationController
  # User must be authenticated before they can interact with accounts
  before_action :authenticate_user!, except: [:create]

  # GET /accounts
  # Returns only accounts the current user has access to
  def index
    accounts = current_user.accounts.page(current_page).per(per_page)
    options = PaginationGenerator.new(request: request, paginated: accounts).generate
    render json: AccountSerializer.new(accounts, options).serialized_json
  end

  # GET /:identifier/account
  def show
    set_account
    render json: AccountSerializer.new(@account).serialized_json
  end

  # POST /accounts
  def create
    p = params
    account = Account.create!(p.slice(:account_name, :account_identifier))
    User.create!(p.slice(:user_name, :user_email, :password, :password_confirmation).merge({ default_account: account }))
    render json: AccountSerializer.new(account).serialized_json, status: :created
  end

  # PATCH/PUT /:identifier/account
  def update
    authorize Account, :update?
    set_account
    @account.update!(permitted_params)
    render json: AccountSerializer.new(@account).serialized_json
  end

  # DELETE /:identifier/account
  def destroy
    authorize Account, :destroy?
    set_account
    @account.discard!
  end

  # PUT /:identifier/account/restore
  def restore
    authorize Account, :restore?
    set_account
    @account.undiscard!
    render json: AccountSerializer.new(@account).serialized_json, status: :ok
  end

  protected
    def permitted_params
      # Account identifier is used for AccountController actions
      params.except(:controller, :action)
    end

  private
    def set_account
      @account = Account.find_by!(identifier: permitted_params.fetch(:identifier))
    end
end
