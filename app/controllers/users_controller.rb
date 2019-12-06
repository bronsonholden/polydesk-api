class UsersController < ApplicationController
  before_action :authenticate_user!, except: [:create]
  after_action :verify_policy_scoped, only: :index

  # GET /users
  def index
    schema = IndexUsersSchema.new(request.params)
    payload = schema.render
    realizer = UserRealizer.new(intent: :index, parameters: payload, headers: request.headers, scope: policy_scope(User))
    authorize realizer.object
    pagination_props = PaginationProperties.new(page_offset, page_limit, realizer.total_count)
    render json: JSONAPI::Serializer.serialize(realizer.object, is_collection: true, meta: pagination_props.generate), status: :ok
  end

  # POST /users
  def create
    schema = CreateUserSchema.new(request.params)
    payload = sanitize_payload(schema.render, User)
    realizer = UserRealizer.new(intent: :create, parameters: payload, headers: request.headers)
    authorize realizer.object
    realizer.object.save!
    render json: JSONAPI::Serializer.serialize(realizer.object), status: :created
  end

  # PATCH /users/:id
  def update
    schema = UpdateUserSchema.new(request.params)
    payload = sanitize_payload(schema.render, User)
    realizer = UserRealizer.new(intent: :update, parameters: payload, headers: request.headers)
    authorize realizer.object
    realizer.object.save!
    render json: JSONAPI::Serializer.serialize(realizer.object), status: :ok
  end

  # GET /users/:id
  def show
    schema = ShowUserSchema.new(request.params)
    payload = schema.render
    realizer = UserRealizer.new(intent: :show, parameters: render, headers: request.headers)
    authorize realizer.object
    render json: JSONAPI::Serializer.serialize(realizer.object), status: :ok
  end

  # DELETE /users/:id
  def destroy
  end
end
