class AccountsController < ApplicationController
  before_action :authenticate_user!

  # GET /accounts
  def index
    schema = IndexAccountsSchema.new(request.params)
    payload = schema.to_hash
    realizer = AccountRealizer.new(intent: :index, parameters: payload, headers: request.headers, scope: policy_scope(Account))
    authorize realizer.object
    pagination_props = PaginationProperties.new(page_offset, page_limit, Account.all.count)
    render json: JSONAPI::Serializer.serialize(realizer.object, is_collection: true, meta: pagination_props.generate)
  end

  # GET /account/:id
  def show
    schema = ShowAccountSchema.new(request.params)
    payload = schema.to_hash
    realizer = AccountRealizer.new(intent: :show, parameters: payload, headers: request.headers)
    authorize realizer.object
    render json: JSONAPI::Serializer.serialize(realizer.object), status: :ok
  end

  # POST /accounts
  def create
    ActiveRecord::Base.transaction do
      schema = CreateAccountSchema.new(request.params)
      payload = sanitize_payload(schema.render, Account)
      realizer = AccountRealizer.new(intent: :create, parameters: payload, headers: request.headers)
      authorize realizer.object
      realizer.object.save!
      realizer.object.account_users.create!(user: current_user, role: :administrator)
      Apartment::Tenant.create(realizer.object.identifier)
      render json: JSONAPI::Serializer.serialize(realizer.object), status: :created
    end
  end

  # PATCH/PUT /accounts/:id
  def update
    schema = UpdateAccountSchema.new(request.params)
    payload = sanitize_payload(schema.to_hash, Account)
    realizer = AccountRealizer.new(intent: :update, parameters: payload, headers: request.headers)
    authorize realizer.object
    realizer.object.save!
    render json: JSONAPI::Serializer.serialize(realizer.object), status: :ok
  end

  # DELETE /accounts/:id
  def destroy
    schema = ShowAccountSchema.new(request.params)
    realizer = AccountRealizer.new(intent: :show, parameters: schema, headers: request.headers)
    authorize realizer.object
    realizer.object.discard!
  end

  # PUT /accounts/:id/restore
  def restore
    schema = ShowAccountSchema.new(request.params)
    realizer = AccountRealizer.new(intent: :show, parameters: schema, headers: request.headers)
    authorize realizer.object, :restore?
    realizer.object.undiscard!
    render json: JSONAPI::Serializer.serialize(realizer.objet), status: :ok
  end

  # Since Accounts are a global resource, fetch current account by the
  # resource ID, not the :identifier path parameter.
  def current_account
    Account.find_by_id(params[:id])
  end

  protected

  # Since Accounts are a global resource, set tenant by the resource ID, not
  # the :identifier path parameter.
  def set_tenant
    id = params['id']
    return if id.nil?
    Apartment::Tenant.switch!(Account.find(id).identifier)
  end
end
