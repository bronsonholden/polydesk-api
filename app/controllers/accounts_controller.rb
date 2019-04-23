class AccountsController < ApplicationController
  # User must be authenticated before they can interact with accounts
  before_action :authenticate_user!, except: [:create]

  # GET /accounts
  # Returns only accounts the current user has access to
  def index
    accounts = current_user.accounts.order('id').page(current_page).per(per_page)
    options = PaginationGenerator.new(request: request, paginated: accounts).generate
    render json: AccountSerializer.new(accounts, options).serialized_json
  end

  # GET /:identifier/account
  def show
    authorize Account, :show?
    set_account
    render json: AccountSerializer.new(@account).serialized_json
  end

  # POST /accounts
  def create
    account = Account.create!(account_create_params)
    User.create!(user_params.merge({ default_account: account }))
    render json: AccountSerializer.new(account).serialized_json, status: :created
  end

  # PATCH/PUT /:identifier/account
  def update
    authorize Account, :update?
    set_account
    @account.update!(account_params)
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_account
      @account = Account.find_by!(identifier: params[:identifier])
    end

    # Only allow a trusted parameter "white list" through.
    def account_params
      params.permit(:name, :identifier)
    end

    def account_create_params
      params.permit(:account_name, :account_identifier)
    end

    def user_params
      params.permit(:user_name, :user_email, :password, :password_confirmation)
    end
end
