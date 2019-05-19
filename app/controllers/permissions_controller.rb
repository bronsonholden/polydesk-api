class PermissionsController < ApplicationController
  include StrongerParameters::ControllerSupport::PermittedParameters

  permitted_parameters :all, { identifier: Parameters.string }
  permitted_parameters :index, { id: Parameters.id }
  permitted_parameters :create, { id: Parameters.id, code: Parameters.string }
  permitted_parameters :destroy, { id:Parameters.id, code: Parameters.string }

  # User must be authenticated before they can interact with permissions
  before_action :authenticate_user!
  before_action :set_account
  before_action :set_user
  before_action :set_account_user

  # POST /:identifier/users/:id/permissions
  def create
    Apartment::Tenant.switch(params[:identifier]) do
      code = permitted_params.fetch(:code)
      @permission = @account_user.permissions.find_by_code(code) || @account_user.permissions.create!(permitted_params.slice(:code))
      render json: PermissionSerializer.new(@permission).serialized_json, status: :created
    end
  end

  def destroy
    Apartment::Tenant.switch(params[:identifier]) do
      @permission = @account_user.permissions.find_by_code(permitted_params.fetch(:code))
      return if @permission.nil?
      @permission.destroy
    end
  end

  # GET /:identifier/users/:id/permissions
  def index
    Apartment::Tenant.switch(params[:identifier]) do
      @permissions = @account_user.permissions.order('id').page(current_page).per(per_page)
      options = PaginationGenerator.new(request: request, paginated: @permissions).generate
      render json: PermissionSerializer.new(@permissions, options).serialized_json, status: :ok
    end
  end

  private
    def permitted_params
      # Account identifier is used for some Permission actions
      params.except(:controller, :action)
    end

    def set_account
      @account = Account.find_by_identifier!(permitted_params.fetch(:identifier))
    end

    def set_user
      @user = User.find(permitted_params.fetch(:id))
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
