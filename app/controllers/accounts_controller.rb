class AccountsController < ApplicationController
  # User must be authenticated before they can interact with accounts
  before_action :authenticate_user!

  # GET /accounts
  def index
    schema = IndexAccountsSchema.new(request.params)
    payload = schema.to_hash
    realizer = AccountRealizer.new(intent: :index, parameters: payload, headers: request.headers, scope: policy_scope(Account))
    render json: JSONAPI::Serializer.serialize(realizer.object, is_collection: true)
  end

  # GET /account/:id
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
      payload = sanitize_payload(schema.to_hash, Account)
      realizer = AccountRealizer.new(intent: :create, parameters: payload, headers: request.headers)
      realizer.object.save!
      realizer.object.users << current_user
      Apartment::Tenant.create(realizer.object.identifier)
      render json: JSONAPI::Serializer.serialize(realizer.object), status: :created
    end
  end

  # PATCH/PUT /accounts/:id
  def update
    authorize Account, :update?
    schema = UpdateAccountSchema.new(request.params)
    payload = sanitize_payload(schema.to_hash, Account)
    realizer = AccountRealizer.new(intent: :update, parameters: payload, headers: request.headers)
    realizer.object.save!
    render json: JSONAPI::Serializer.serialize(realizer.object), status: :ok
  end

  # DELETE /accounts/:id
  def destroy
    authorize Account, :destroy?
    schema = ShowAccountSchema.new(request.params)
    realizer = AccountRealizer.new(intent: :show, parameters: schema, headers: request.headers)
    realizer.object.discard!
  end

  # PUT /accounts/:id/restore
  def restore
    authorize Account, :restore?
    schema = ShowAccountSchema.new(request.params)
    realizer = AccountRealizer.new(intent: :show, parameters: schema, headers: request.headers)
    realizer.object.undiscard!
    render json: JSONAPI::Serializer.serialize(realizer.objet), status: :ok
  end

  def current_account
    Account.find_by_id(params[:id])
  end

  protected

  def set_tenant
    id = params['id']
    return if id.nil?
    Apartment::Tenant.switch!(Account.find(id).identifier)
  end
end
