class PermissionsController < ApplicationController
  # User must be authenticated before they can interact with permissions
  before_action :authenticate_user!
  before_action :set_account
  before_action :set_user
  before_action :set_account_user

  # POST /:identifier/users/:id/permissions
  def create
    Apartment::Tenant.switch(params[:identifier]) do
      @permission = Permission.find_by_code(params[:code]) || Permission.create!(permission_params)
      render json: PermissionSerializer.new(@permission).serialized_json, status: :created
    end
  end

  def destroy
    Apartment::Tenant.switch(params[:identifier]) do
      @permission = Permission.find_by_code(params[:code])
      return if @permission.nil?
      @permission.destroy
    end
  end

  # GET /:identifier/users/:id/permissions
  def index
    Apartment::Tenant.switch(params[:identifier]) do
      @permissions = Permission.where(account_user_id: @account_user.user_id).order('id').page(current_page).per(per_page)
      options = PaginationGenerator.new(request: request, paginated: @permissions).generate
      render json: PermissionSerializer.new(@permissions, options).serialized_json, status: :ok
    end
  end

  private
    def set_account
      @account = Account.find_by_identifier!(params[:identifier])
    end

    def set_user
      @user = Account.find(params[:id])
    end

    def set_account_user
      @account_user = AccountUser.find_by!(account_id: @account.id,
                                           user_id: @user.id)
    end

    def permission_params
      p = params.permit(:code)
      p[:account_user_id] = @account_user.id
      return p
    end
end
