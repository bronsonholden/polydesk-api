class PermissionsController < ApplicationController
  # User must be authenticated before they can interact with permissions
  before_action :authenticate_user!

  def new
  end

  # POST /:identifier/users/:id/permissions
  def create
    Apartment::Tenant.switch(params[:identifier]) do
      @permission = Permission.new(permission_params)
      #authorize @permission
      if @permission.save
        render json: @permission, status: :ok
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
      render json: @permissions, status: :ok
    end
  end

  private
    def permission_params
      account = Account.find_by identifier: params[:identifier]
      account_user = AccountUser.find_by account_id: account.id, user_id: params[:id]
      p = params.require(:permission).permit(:code)
      p[:account_user_id] = account_user.id
      return p
    end
end
