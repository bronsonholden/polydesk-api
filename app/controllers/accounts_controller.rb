class AccountsController < ApplicationController
  # Retrieve account resource by identifier parameter
  before_action :set_account, only: [:show, :update, :destroy]
  # User must be authenticated before they can interact with accounts
  before_action :authenticate_user!, except: [:create]

  # GET /accounts
  # Returns only accounts the current user has access to
  def index
    accounts = current_user.accounts
    render json: accounts
  end

  # GET /:identifier/account
  def show
    identifier = params[:identifier]
    account = current_user.accounts.where(identifier: identifier)
    if account.length == 1
      render json: account
    else
      render json: {errors: {user: ["does not have access to #{identifier}"]}}, status: :forbidden
    end
  end

  # POST /accounts
  def create
    ActiveRecord::Base.transaction do
      # Create account and default user
      account = Account.create(account_create_params)
      user = User.create(user_params)
      account_user = AccountUser.create(account: account, user: user)

      # Validate records, stop and return any errors
      [account, user, account_user].each { |record|
        unless record.valid?
          render json: record.errors, status: :unprocessable_entity
          return false
        end
      }

      # All records created successfully, create the tenant
      Apartment::Tenant.create(account.identifier)
      render json: account, status: :created, location: account
    end
  end

  # PATCH/PUT /:identifier/account
  def update
    if @account.update(account_params)
      render json: @account
    else
      render json: @account.errors, status: :unprocessable_entity
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
