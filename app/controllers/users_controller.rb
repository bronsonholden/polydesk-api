class UsersController < ApplicationController
  # GET /:identifier/users
  def index
    @account = Account.where(identifier: params[:identifier]).first
    render json: UserSerializer.new(@account.users).serialized_json
  end

  def show
    @account = Account.find_by! identifier: params[:identifier]
    @user = User.find_by! id: params[:id]

    if AccountUser.where(account_id: @account.id, user: @user.id).empty?
      render json: {errors: {user: ["does not exist in #{params[:identifier]}"]}}, status: :unprocessable_entity
    else
      render json: UserSerializer.new(@user).serialized_json, status: :ok
    end
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
