class UsersController < ApplicationController
  before_action :authenticate_user!, except: [:create]

  # GET /users
  def index
    schema = IndexUsersSchema.new(request.params)
    realizer = UserRealizer.new(intent: :index, parameters: schema, headers: request.headers)
    render json: JSONAPI::Serializer.serialize(realizer.object, is_collection: true), status: :ok
  end

  # POST /users
  # Create user while not authenticated.
  def create
    schema = CreateUserSchema.new(request.params)
    # Since we're not authenticated, we can't use policies to permit
    # attributes.
    payload = schema.to_hash
    payload.dig('data').slice!('attributes')
    realizer = UserRealizer.new(intent: :create, parameters: payload, headers: request.headers)
    realizer.object.save!
    render json: JSONAPI::Serializer.serialize(realizer.object), status: :created
  end

  # POST /:identifier/users
  def create_auth
    schema = CreateUserSchema.new(request.params)
    payload = sanitize_payload(schema.to_hash, User)
    realizer = UserRealizer.new(intent: :create, parameters: payload, headers: request.headers)
    realizer.object.save!
    render json: JSONAPI::Serializer.serialize(realizer.object), status: :created
  end

  # PATCH /users/:id
  def update
    schema = UpdateUserSchema.new(request.params)
    payload = sanitize_payload(schema.to_hash, User)
    realizer = UserRealizer.new(intent: :update, parameters: payload, headers: request.headers)
    realizer.object.save!
    render json: JSONAPI::Serializer.serialize(realizer.object), status: :ok
  end

  # GET /users/:id
  def show
    schema = ShowUserSchema.new(request.params)
    realizer = UserRealizer.new(intent: :show, parameters: schema, headers: request.headers)
    render json: JSONAPI::Serializer.serialize(realizer.object), status: :ok
  end

  # DELETE /users/:id
  def destroy
  end
end
