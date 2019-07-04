class UsersController < ApplicationController
  before_action :authenticate_user!, except: [:create]

  # GET /users
  def index
    authorize User, :index?
    schema = IndexUsersSchema.new(request.params)
    realizer = UserRealizer.new(intent: :index, parameters: schema, headers: request.headers)
    pagination_props = PaginationProperties.new(page_offset, page_limit, realizer.object.size)
    render json: JSONAPI::Serializer.serialize(realizer.object, is_collection: true, meta: pagination_props), status: :ok
  end

  # POST /users
  def create
    authorize User, :create?
    schema = CreateUserSchema.new(request.params)
    payload = sanitize_payload(schema.to_hash, User)
    realizer = UserRealizer.new(intent: :create, parameters: payload, headers: request.headers)
    realizer.object.save!
    render json: JSONAPI::Serializer.serialize(realizer.object), status: :created
  end

  # PATCH /users/:id
  def update
    authorize User, :update?
    schema = UpdateUserSchema.new(request.params)
    payload = sanitize_payload(schema.to_hash, User)
    realizer = UserRealizer.new(intent: :update, parameters: payload, headers: request.headers)
    realizer.object.save!
    render json: JSONAPI::Serializer.serialize(realizer.object), status: :ok
  end

  # GET /users/:id
  def show
    authorize User, :show?
    schema = ShowUserSchema.new(request.params)
    realizer = UserRealizer.new(intent: :show, parameters: schema, headers: request.headers)
    render json: JSONAPI::Serializer.serialize(realizer.object), status: :ok
  end

  # DELETE /users/:id
  def destroy
  end
end
