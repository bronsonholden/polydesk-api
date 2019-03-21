class AccountsController < ApplicationController
  # Retrieve account resource by identifier parameter
  before_action :set_account, only: [:show, :update, :destroy]
  # User must be authenticated before they can interact with accounts
  before_action :authenticate_user!, except: [:create]

  # GET /accounts
  # Returns only accounts the current user has access to
  def index
    accounts = current_user.accounts
    render json: AccountSerializer.new(accounts).serialized_json
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
    # Don't proceed to tenant creation if
    if params[:account_identifier].nil?
      @account = Account.new
      @account.errors.add('account_identifier', 'is required')
      render json: ErrorSerializer.new(@account.errors).serialized_json,
             status: :unprocessable_entity
      return
    end

    # All records created successfully, create the tenant
    Apartment::Tenant.create(params[:account_identifier])

    Apartment::Tenant.switch(params[:account_identifier]) do
      ActiveRecord::Base.transaction do
        # Create account and default user
        account = Account.new(account_create_params)
        unless account.save
          render json: ErrorSerializer.new(account.errors).serialized_json, status: :unprocessable_entity
          return false
        end

        user = User.new(user_params)
        user.default_account = account
        unless user.save
          render json: ErrorSerializer.new(user.errors).serialized_json, status: :unprocessable_entity
          return false
        end

        account_user = AccountUser.create(account_id: account.id, user_id: user.id)

        render json: AccountSerializer.new(account).serialized_json, status: :created
      end
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
