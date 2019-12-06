class AccountUsersController < ApplicationController
  before_action :authenticate_user!

  # POST /:identifier/users
  def create
  end

  # GET /:identifier/users
  def index
    schema = IndexUsersSchema.new(request.params)
    payload = schema.render
    realizer = UserRealizer.new(intent: :index, parameters: payload, headers: request.headers, scope: policy_scope(User))
    authorize realizer.object
    pagination_props = PaginationProperties.new(page_offset, page_limit, User.all.count)
    render json: JSONAPI::Serializer.serialize(realizer.object.except(:order).order('users.id'), is_collection: true, meta: pagination_props.generate), status: :ok
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
