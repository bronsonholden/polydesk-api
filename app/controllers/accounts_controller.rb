class AccountsController < ApplicationController
  # Retrieve account resource by identifier parameter
  before_action :set_account, only: [:show, :update, :destroy]
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
    set_account

    if @account
      user_account = current_user.accounts.where(identifier: @account.identifier)

      if user_account.length == 1
        render json: AccountSerializer.new(@account).serialized_json
        return
      end
    end

    # If no account object, create it to serialize errors
    @account ||= Account.new(identifier: params[:identifier])
    # Only error we want to return is no access
    @account.errors.add('user', "does not have access to #{@account.identifier}")

    render json: ErrorSerializer.new(@account.errors).serialized_json, status: :forbidden
  end

  # POST /accounts
  def create
    # Create account and user
    ActiveRecord::Base.transaction do
      account = Account.create!(account_create_params)
      User.create!(user_params.merge({ default_account: account }))
      render json: AccountSerializer.new(account).serialized_json, status: :created
    end
  end

  # PATCH/PUT /:identifier/account
  def update
    if @account.update(account_params)
      render json: AccountSerializer.new(@account).serialized_json
    else
      render json: ErrorSerializer.new(@account.errors).serialized_json, status: :unprocessable_entity
    end
  end

  # DELETE /:identifier/account
  def destroy
    @account.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_account
      @account = Account.find_by_identifier(params[:identifier])
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
