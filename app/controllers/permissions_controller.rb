class PermissionsController < ApplicationController
  # User must be authenticated before they can interact with permissions
  before_action :authenticate_user!
  before_action :set_account
  before_action :set_user
  before_action :set_account_user

  def new
  end

  # POST /:identifier/users/:id/permissions
  def create
    Apartment::Tenant.switch(params[:identifier]) do
      @permission = Permission.new(permission_params)
      #authorize @permission
      if @permission.save
        render json: PermissionSerializer.new(@permission).serialized_json, status: :ok
      else
        render json: @permission.errors, status: :unprocessable_entity
      end
    end
  end

  # GET /:identifier/users/:id/permissions
  def index
    Apartment::Tenant.switch(params[:identifier]) do
      @permissions = Permissions.where(user_id: params[:id])
      #authorize @permissions
      render json: PermissionSerializer.new(@permissions).serialized_json, status: :ok
    end
  end

  private
    def set_account
      @account = Account.find_by! identifier: params[:identifier]
    rescue ActiveRecord::RecordNotFound
      render json: {errors: {account: ['does not exist']}},
             status: :unprocessable_entity
      return
    end

    def set_user
      @user = User.find_by! id: params[:id]
    rescue ActiveRecord::RecordNotFound
      render json: {errors: {user: ['does not exist']}},
             status: :unprocessable_entity
      return
    end

    def set_account_user
      @account_user = AccountUser.find_by! account_id: @account.id,
                                           user_id: @user.id
    rescue ActiveRecord::RecordNotFound
      render json: {errors: {user: ['does not have access to this account']}},
             status: :unprocessable_entity
      return
    end

    def permission_params
      p = params.require(:permission).permit(:code)
      p[:account_user_id] = @account_user.id
      return p
    end
end
