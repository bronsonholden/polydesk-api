class UsersController < ApplicationController
  include StrongerParameters::ControllerSupport::PermittedParameters

  permitted_parameters :all, { identifier: Parameters.string }
  permitted_parameters :index, { user: {} }
  permitted_parameters :show, { id: Parameters.id }
  permitted_parameters :destroy, { id: Parameters.id }

  before_action :authenticate_user!

  # GET /:identifier/users
  def index
    Apartment::Tenant.switch(params[:identifier]) do
      account = Account.find_by_identifier!(params[:identifier])
      @account_users = AccountUser.where(account_id: account.id)
                                  .includes('user')
                                  .order('id')
                                  .page(current_page).per(per_page)
      options = PaginationGenerator.new(request: request, paginated: @account_users).generate
      render json: AccountUserSerializer.new(@account_users, options).serialized_json
    end
  end

  # GET /:identifier/users/:id
  def show
    Apartment::Tenant.switch(params[:identifier]) do
      @account_user = AccountUser.find_by!(user_id: params[:id]).includes('user')
      render json: AccountUserSerializer.new(@account_user).serialized_json, status: :ok
    end
  end

  # DELETE /:identifier/users/:id
  def destroy
    # Delete while in the tenant schema so associated records can be destroyed
    Apartment::Tenant.switch(params[:identifier]) do
      @account = Account.where(identifier: params[:identifier]).first
      AccountUser.find_by!(user_id: params[:id], account_id: @account.id).destroy
    end
  end
end
