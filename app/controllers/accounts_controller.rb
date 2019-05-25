class AccountsController < ApplicationController
  # User must be authenticated before they can interact with accounts
  before_action :authenticate_user!, except: [:create]

  # GET /:identifier/account
  def show
    schema = ShowAccountSchema.new(request.params)
    realizer = AccountRealizer.new(intent: :show, parameters: schema, headers: request.headers)
    render json: JSONAPI::Serializer.serialize(realizer.object), status: :ok
  end

  # POST /accounts
  def create
    account = Account.create!(account_create_params)
    User.create!(user_params.merge({ default_account: account }))
    render json: AccountSerializer.new(account).serialized_json, status: :created
  end

  # PATCH/PUT /:identifier/account
  def update
    authorize Account, :update?
    schema = UpdateAccountSchema.new(request.params)
    realizer = AccountRealizer.new(intent: :update, parameters: schema, headers: request.headers)
    realizer.object.save!
    render json: JSONAPI::Serializer.serialize(realizer.object), status: :ok
  end

  # DELETE /:identifier/account
  def destroy
    authorize Account, :destroy?
    schema = ShowAccountSchema.new(request.params)
    realizer = AccountRealizer.new(intent: :show, parameters: schema, headers: request.headers)
    realizer.object.discard!
  end

  # PUT /:identifier/account/restore
  def restore
    authorize Account, :restore?
    schema = ShowAccountSchema.new(request.params)
    realizer = AccountRealizer.new(intent: :show, parameters: schema, headers: request.headers)
    realizer.object.undiscard!
    render json: JSONAPI::Serializer.serialize(realizer.objet), status: :ok
  end

  private

  def account_params
    params.permit(:name, :identifier)
  end

  def account_create_params
    params.permit(:account_name, :account_identifier)
  end

  def user_params
    params.permit(:user_name, :user_email, :password, :password_confirmation)
  end
end
