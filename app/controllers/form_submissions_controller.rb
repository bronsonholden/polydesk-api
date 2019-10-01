class FormSubmissionsController < ApplicationController
  before_action :authenticate_user!

  # GET /:identifier/form-submissions
  def index
    submissions_schema = IndexFormSubmissionsSchema.new(request.params)
    submissions_payload = submissions_schema.render
    submissions_scope = policy_scope(FormSubmission)
    filter = FormSubmissionFiltering.new(submissions_payload)
    submissions_scope = filter.apply(submissions_scope)
    sorter = FormSubmissionSorting.new(submissions_payload)
    submissions_scope = sorter.apply(submissions_scope)
    submissions_payload = sorter.payload
    submissions_realizer = FormSubmissionRealizer.new(intent: :index, parameters: submissions_payload, headers: request.headers, scope: submissions_scope)
    authorize submissions_realizer.object, :index?
    pagination_props = PaginationProperties.new(page_offset, page_limit, submissions_realizer.total_count)
    render json: JSONAPI::Serializer.serialize(submissions_realizer.object, is_collection: true, meta: pagination_props.generate), status: :ok
    #
    # schema = IndexFormSubmissionsSchema.new(request.params)
    # payload = schema.render
    # realizer = FormSubmissionRealizer.new(intent: :index, parameters: payload, headers: request.headers)
    # authorize realizer.object
    # pagination_props = PaginationProperties.new(page_offset, page_limit, realizer.total_count)
    # render json: JSONAPI::Serializer.serialize(realizer.object, is_collection: true, meta: pagination_props.generate), status: :ok
  end

  # POST /:identifier/form-submissions
  def create
    schema = CreateFormSubmissionSchema.new(request.params)
    payload = sanitize_payload(schema.render, FormSubmission)
    realizer = FormSubmissionRealizer.new(intent: :create, parameters: payload, headers: request.headers)
    authorize realizer.object
    form = realizer.object.form
    authorize form, :show?
    # Verify no unique fields are violated
    form.unique_fields.each { |key|
      parts = key.split('.')
      val = payload.dig('data', 'attributes', 'data', *parts)
      # Build and sanitize order SQL
      col = parts.reduce('data') { |sql, part|
        "#{sql}->>#{ActiveRecord::Base.connection.quote(part)}"
      }
      if FormSubmission.where("#{col} = ?", Arel.sql(val.to_s)).any?
        raise Polydesk::Errors::UniqueFieldViolation.new(key)
      end
    }
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
    payload = sanitize_payload(schema.render, FormSubmission)
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
