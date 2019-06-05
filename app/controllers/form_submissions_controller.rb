class FormSubmissionsController < ApplicationController

  # GET /:identifier/form-submissions
  def index
    schema = IndexFormSubmissionsSchema.new(request.params)
    realizer = FormSubmissionRealizer.new(intent: :index, parameters: schema.to_hash, headers: request.headers)
    render json: JSONAPI::Serializer.serialize(realizer.object, is_collection: true), status: :ok
  end

  # POST /:identifier/form-submissions
  def create
    schema = CreateFormSubmissionSchema.new(request.params)
    payload = sanitize_payload(schema.to_hash, FormSubmission)
    realizer = FormSubmissionRealizer.new(intent: :create, parameters: payload, headers: request.headers)
    realizer.object.submitter = current_user
    realizer.object.save!
    render json: JSONAPI::Serializer.serialize(realizer.object), status: :created
  end

    # GET /:identifier/form-submissions/:id
  def show
    schema = ShowFormSubmissionSchema.new(request.params)
    payload = sanitize_payload(schema.to_hash, FormSubmission)
    realizer = FormSubmissionRealizer.new(intent: :show, parameters: payload, headers: request.headers)
    render json: JSONAPI::Serializer.serialize(realizer.object), status: :ok
  end

  # PATCH /:identifier/form-submissions/:id
  def update
    schema = UpdateFormSubmissionSchema.new(request.params)
    payload = sanitize_payload(schema.to_hash, FormSubmission)
    realizer = FormSubmissionRealizer.new(intent: :update, parameters: payload, headers: request.headers)
    realizer.object.save!
    render json: JSONAPI::Serializer.serialize(realizer.object), status: :ok
  end

  # DELETE /:identifier/form-submissions/:id
  def destroy
    schema = ShowFormSubmissionSchema.new(request.params)
    payload = sanitize_payload(schema.to_hash, FormSubmission)
    realizer = FormSubmissionRealizer.new(intent: :show, parameters: payload, headers: request.headers)
    realizer.object.destroy!
  end
end
