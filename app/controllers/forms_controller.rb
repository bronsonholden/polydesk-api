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
    payload = schema.render
    realizer = FormRealizer.new(intent: :index, parameters: payload, headers: request.headers, scope: policy_scope(Form))
    authorize realizer.object
    pagination_props = PaginationProperties.new(page_offset, page_limit, realizer.total_count)
    render json: JSONAPI::Serializer.serialize(realizer.object, is_collection: true, meta: pagination_props.generate), status: :ok
  end

  # GET /:identifier/forms/:id
  def show
    schema = ShowFormSchema.new(request.params)
    payload = schema.render
    realizer = FormRealizer.new(intent: :show, parameters: payload, headers: request.headers)
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
    payload = schema.render
    realizer = FormRealizer.new(intent: :show, parameters: payload, headers: request.headers)
    authorize realizer.object
    realizer.object.discard!
  end

  # GET /:identifier/forms/:id/form_submissions
  def form_submissions
    form_schema = ShowFormSchema.new(request.params)
    form_payload = form_schema.render
    submissions_schema = IndexFormSubmissionsSchema.new(request.params)
    submissions_payload = submissions_schema.render
    form_realizer = FormRealizer.new(intent: :show, parameters: form_payload, headers: request.headers)
    authorize form_realizer.object, :show?
    submissions_scope = FormSubmission.where(form: form_realizer.object)
    sorter = FormSubmissionSorting.new(submissions_payload)
    submissions_scope = sorter.apply(submissions_scope)
    submissions_payload = sorter.payload
    submissions_realizer = FormSubmissionRealizer.new(intent: :index, parameters: submissions_payload, headers: request.headers, scope: submissions_scope)
    authorize submissions_realizer.object, :index?
    pagination_props = PaginationProperties.new(page_offset, page_limit, submissions_realizer.total_count)
    render json: JSONAPI::Serializer.serialize(submissions_realizer.object, is_collection: true, meta: pagination_props.generate), status: :ok
  end

  private

  # Helper to get payload but convert schema (the form schema) to a
  # JSON string
  def get_payload(schema)
    payload = schema.render
    json = payload.dig("data", "attributes", "schema")
    if !json.nil?
      payload["data"]["attributes"]["schema"] = json.to_json
    end
    payload
  end
end
