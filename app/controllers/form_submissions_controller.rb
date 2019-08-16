class FormSubmissionsController < ApplicationController
  before_action :authenticate_user!

  # GET /:identifier/form-submissions
  def index
    schema = IndexFormSubmissionsSchema.new(request.params)
    payload = schema.render
    realizer = FormSubmissionRealizer.new(intent: :index, parameters: payload, headers: request.headers)
    authorize realizer.object
    render json: JSONAPI::Serializer.serialize(realizer.object, is_collection: true), status: :ok
  end

  # POST /:identifier/form-submissions
  def create
    schema = CreateFormSubmissionSchema.new(request.params)
    payload = sanitize_payload(schema.render, FormSubmission)
    realizer = FormSubmissionRealizer.new(intent: :create, parameters: payload, headers: request.headers)
    authorize realizer.object
    realizer.object.submitter = current_user
    realizer.object.schema_snapshot = realizer.object.form.schema
    realizer.object.layout_snapshot = realizer.object.form.layout
    realizer.object.save!
    realizer.object.transition_to!(:published) if payload.dig('data', 'attributes', 'state') != 'draft'
    render json: JSONAPI::Serializer.serialize(realizer.object), status: :created
  end

  # GET /:identifier/form-submissions/:id
  def show
    schema = ShowFormSubmissionSchema.new(request.params)
    payload = sanitize_payload(schema.render, FormSubmission)
    realizer = FormSubmissionRealizer.new(intent: :show, parameters: payload, headers: request.headers)
    authorize realizer.object
    render json: JSONAPI::Serializer.serialize(realizer.object), status: :ok
  end

  # PATCH /:identifier/form-submissions/:id
  def update
    schema = UpdateFormSubmissionSchema.new(request.params)
    payload = sanitize_payload(schema.to_hash, FormSubmission)
    realizer = FormSubmissionRealizer.new(intent: :update, parameters: payload, headers: request.headers)
    authorize realizer.object
    realizer.object.save!
    render json: JSONAPI::Serializer.serialize(realizer.object), status: :ok
  end

  # DELETE /:identifier/form-submissions/:id
  def destroy
    schema = ShowFormSubmissionSchema.new(request.params)
    payload = sanitize_payload(schema.render, FormSubmission)
    realizer = FormSubmissionRealizer.new(intent: :show, parameters: payload, headers: request.headers)
    authorize realizer.object
    realizer.object.destroy!
  end
end
