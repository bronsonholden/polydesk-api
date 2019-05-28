class AccountsController < ApplicationController
  # User must be authenticated before they can interact with accounts
  before_action :authenticate_user!

  # GET /:identifier/account
  def show
    schema = ShowAccountSchema.new(request.params)
    payload = schema.to_hash
    # Since Account paths don't specify an ID in the path
    payload.merge!({ 'id' => schema.id })
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

  # PATCH/PUT /:identifier/account
  def update
    authorize Account, :update?
    schema = UpdateAccountSchema.new(request.params)
    payload = sanitize_payload(schema.to_hash, Account)
    # Since Account paths don't specify an ID in the path
    payload.merge!({ 'id' => schema.id })
    realizer = AccountRealizer.new(intent: :update, parameters: payload, headers: request.headers)
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
end
