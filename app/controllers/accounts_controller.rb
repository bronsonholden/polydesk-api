class AccountsController < ApplicationController
  # User must be authenticated before they can interact with accounts
  before_action :authenticate_user!

  # GET /account/1
  def show
    schema = ShowAccountSchema.new(request.params)
    payload = schema.to_hash
    realizer = AccountRealizer.new(intent: :show, parameters: payload, headers: request.headers)
    render json: JSONAPI::Serializer.serialize(realizer.object), status: :ok
  end

  # POST /accounts
  def create
    ActiveRecord::Base.transaction do
      schema = CreateAccountSchema.new(request.params)
      realizer = AccountRealizer.new(intent: :create, parameters: schema, headers: request.headers)
      realizer.object.save!
      Apartment::Tenant.create(realizer.object.identifier)
      render json: JSONAPI::Serializer.serialize(realizer.object), status: :created
    end
  end

  # PATCH/PUT /accounts/1
  def update
    authorize Account, :update?
    schema = UpdateAccountSchema.new(request.params)
    payload = sanitize_payload(schema.to_hash, Account)
    realizer = AccountRealizer.new(intent: :update, parameters: payload, headers: request.headers)
    realizer.object.save!
    render json: JSONAPI::Serializer.serialize(realizer.object), status: :ok
  end

  # DELETE /accounts/1
  def destroy
    authorize Account, :destroy?
    schema = ShowAccountSchema.new(request.params)
    realizer = AccountRealizer.new(intent: :show, parameters: schema, headers: request.headers)
    realizer.object.discard!
  end

  # PUT /accounts/1/restore
  def restore
    authorize Account, :restore?
    schema = ShowAccountSchema.new(request.params)
    realizer = AccountRealizer.new(intent: :show, parameters: schema, headers: request.headers)
    realizer.object.undiscard!
    render json: JSONAPI::Serializer.serialize(realizer.objet), status: :ok
  end

  def current_account
    Account.find(params[:id])
  end
end
