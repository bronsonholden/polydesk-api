class UsersController < ApplicationController
  # GET /:identifier/users
  def index
    @account = Account.where(identifier: params[:identifier]).first
    render json: @account.users
  end

  # For development/testing. All users of all accounts
  def index_all
    @users = User.all
    render json: @users
  end
end
