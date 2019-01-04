class UsersController < ApplicationController
  # GET /:identifier/users
  def index
    @account = Account.where(identifier: params[:identifier]).first
    render json: @account.users
  end

  def show
    @account = Account.find_by! identifier: params[:identifier]
    @user = User.find_by! id: params[:id]

    if AccountUser.where(account_id: @account.id, user: @user.id).empty?
      render json: {errors: {user: ["does not exist in #{params[:identifier]}"]}}, status: :unprocessable_entity
    else
      render json: @user, status: :ok
    end
  end

  # DELETE /:identifier/users/:id
  def destroy
    @account = Account.where(identifier: params[:identifier]).first
    AccountUser.find_by!(user_id: params[:id], account_id: @account.id).destroy
    render json: {}, status: :ok
  end

  # For development/testing. All users of all accounts
  def index_all
    @users = User.all
    render json: @users
  end
end
