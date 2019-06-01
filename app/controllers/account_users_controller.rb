class AccountUsersController < ApplicationController
  before_action :authenticate_user!

  # POST /:identifier/users
  def create
  end

  # GET /:identifier/users
  def index
  end

  # GET /:identifier/users/:id
  def show
  end

  # DELETE /:identifier/users/:id
  def destroy
  end

  # PATCH /:identifier/users/:id
  def update
  end
end
