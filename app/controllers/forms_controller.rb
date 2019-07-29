class FormsController < ApplicationController
  before_action :authenticate_user!

  # POST /:identifier/forms
  def create
    schema = CreateFormSchema.new(request.params)
    payload = get_payload(schema)
    realizer = FormRealizer.new(intent: :create, parameters: payload, headers: request.headers)
    authorize realizer.object
    realizer.object.save!
    render json: JSONAPI::Serializer.serialize(realizer.object), status: :created
  end

  # GET /:identifier/forms
  def index
    schema = IndexFormsSchema.new(request.params)
    realizer = FormRealizer.new(intent: :index, parameters: schema, headers: request.headers)
    authorize realizer.object
    pagination_props = PaginationProperties.new(page_offset, page_limit, realizer.object.size)
    render json: JSONAPI::Serializer.serialize(realizer.object, is_collection: true, meta: pagination_props.generate), status: :ok
  end

  # GET /:identifier/forms/:id
  def show
    schema = ShowFormSchema.new(request.params)
    realizer = FormRealizer.new(intent: :show, parameters: schema, headers: request.headers)
    authorize realizer.object
    render json: JSONAPI::Serializer.serialize(realizer.object), status: :ok
  end

  # PATCH/PUT /:identifier/forms/:id
  def update
    schema = UpdateFormSchema.new(request.params)
    payload = get_payload(schema)
    realizer = FormRealizer.new(intent: :update, parameters: payload, headers: request.headers)
    authorize realizer.object
    realizer.object.save!
    render json: JSONAPI::Serializer.serialize(realizer.object), status: :ok
  end

  # DELETE /:identifier/forms/:id
  def destroy
    schema = ShowFormSchema.new(request.params)
    realizer = FormRealizer.new(intent: :show, parameters: schema, headers: request.headers)
    authorize realizer.object
    realizer.object.discard!
  end

  # GET /:identifier/forms/:id/form_submissions
  def form_submissions
    schema = ShowFormSchema.new(request.params)
    realizer = FormRealizer.new(intent: :show, parameters: schema, headers: request.headers)
    authorize realizer.object, :show?
    render json: JSONAPI::Serializer.serialize(realizer.object.form_submissions, is_collection: true), status: :ok
  end

  private

  # Helper to get payload but convert schema (the form schema) to a
  # JSON string
  def get_payload(schema)
    payload = schema.to_hash
    json = payload.dig("data", "attributes", "schema")
    if !json.nil?
      payload["data"]["attributes"]["schema"] = json.to_json
    end
    payload
  end
end
