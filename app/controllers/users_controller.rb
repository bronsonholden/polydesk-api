class UsersController < ApplicationController
  before_action :authenticate_user!

  # GET /:identifier/users
  def index
    @account = Account.where(identifier: params[:identifier]).first
    users = @account.users.order('id').page(current_page).per(per_page)
    options = PaginationGenerator.new(request: request, paginated: users).generate
    render json: UserSerializer.new(users, options).serialized_json
  end

  # GET /:identifier/users/:id
  def show
    @account_user = AccountUser.find_by!(user_id: params[:id])
    @user = User.find(params[:id])
    render json: UserSerializer.new(@user).serialized_json, status: :ok
  end

  # DELETE /:identifier/users/:id
  def destroy
    # Delete while in the tenant schema so associated records can be destroyed
    Apartment::Tenant.switch(params[:identifier]) do
      @account = Account.where(identifier: params[:identifier]).first
      AccountUser.find_by!(user_id: params[:id], account_id: @account.id).destroy
    end

    render json: {}, status: :ok
  end

  # For development/testing. All users of all accounts
  def index_all
    @users = User.all
    render json: UserSerializer.new(@users).serialized_json
  end
end
