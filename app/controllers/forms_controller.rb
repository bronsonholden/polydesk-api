class FormsController < ApplicationController
  before_action :authenticate_user!

  # POST /:identifier/forms
  def create
    authorize Form, :create?
    schema = CreateFormSchema.new(request.params)
    realizer = FormRealizer.new(intent: :create, parameters: schema, headers: request.headers)
    realizer.object.save!
    render json: JSONAPI::Serializer.serialize(realizer.object), status: :created
  end

  # GET /:identifier/forms
  def index
    authorize Form, :index?
    schema = IndexFormsSchema.new(request.params)
    realizer = FormRealizer.new(intent: :index, parameters: schema, headers: request.headers)
    pagination_props = PaginationProperties.new(page_offset, page_limit, realizer.object.size)
    render json: JSONAPI::Serializer.serialize(realizer.object, is_collection: true, meta: pagination_props), status: :ok
  end

  # GET /:identifier/forms/:id
  def show
    authorize Form, :show?
    schema = ShowFormSchema.new(request.params)
    realizer = FormRealizer.new(intent: :show, parameters: schema, headers: request.headers)
    render json: JSONAPI::Serializer.serialize(realizer.object), status: :ok
  end

  # PATCH/PUT /:identifier/forms/:id
  def update
    authorize Form, :update?
    schema = UpdateFormSchema.new(request.params)
    realizer = FormRealizer.new(intent: :update, parameters: schema, headers: request.headers)
    realizer.object.save!
    render json: JSONAPI::Serializer.serialize(realizer.object), status: :ok
  end

  # DELETE /:identifier/forms/:id
  def destroy
    authorize Form, :destroy?
    schema = ShowFormSchema.new(request.params)
    realizer = FormRealizer.new(intent: :show, parameters: schema, headers: request.headers)
    realizer.object.discard!
  end
end
