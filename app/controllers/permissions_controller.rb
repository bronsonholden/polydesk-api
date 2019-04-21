class PermissionsController < ApplicationController
  # User must be authenticated before they can interact with permissions
  before_action :authenticate_user!
  before_action :set_account
  before_action :set_user
  before_action :set_account_user

  # POST /:identifier/users/:id/permissions
  def create
    Apartment::Tenant.switch(params[:identifier]) do
      @permission = Permission.create!(permission_params)
      render json: PermissionSerializer.new(@permission).serialized_json, status: :ok
    end
  end

  # GET /:identifier/users/:id/permissions
  def index
    Apartment::Tenant.switch(params[:identifier]) do
      @permissions = Permissions.where(user_id: params[:id]).order('id').page(current_page).per(per_page)
      options = PaginationGenerator.new(request: request, paginated: @permissions).generate
      render json: PermissionSerializer.new(@permissions, options).serialized_json, status: :ok
    end
  end

  private
    def set_account
      @account = Account.find_by! identifier: params[:identifier]
    rescue ActiveRecord::RecordNotFound
      # Probably want to return an error about user access to account
      # instead of account existence
      @account = Account.new
      @account.errors.add('account', 'does not exist')
      render json: ErrorSerializer.new(@account.errors).serialized_json,
             status: :unprocessable_entity
      return
    end

    def set_user
      @user = User.find_by! id: params[:id]
    rescue ActiveRecord::RecordNotFound
      @user = User.new
      @user.errors.add('user', 'does not exist')
      render json: ErrorSerializer.new(@user.errors).serialized_json,
             status: :unprocessable_entity
      return
    end

    def set_account_user
      @account_user = AccountUser.find_by! account_id: @account.id,
                                           user_id: @user.id
    rescue ActiveRecord::RecordNotFound
      @account_user = AccountUser.new
      @account_user.errors.add(user, 'does not have access to this account')
      render json: ErrorSerializer.new(@account_user).serialized_json,
             status: :unprocessable_entity
      return
    end

    def permission_params
      p = params.require(:permission).permit(:code)
      p[:account_user_id] = @account_user.id
      return p
    end
end
