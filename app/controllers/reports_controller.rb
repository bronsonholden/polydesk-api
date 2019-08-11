class ReportsController < ApplicationController
  before_action :authenticate_user!

  # GET /:identifier/reports
  def index
    schema = IndexReportsSchema.new(request.params)
    realizer = ReportRealizer.new(intent: :index, parameters: schema, headers: request.headers)
    authorize realizer.object
    pagination_props = PaginationProperties.new(page_offset, page_limit, Report.all.count)
    render json: JSONAPI::Serializer.serialize(realizer.object, is_collection: true, meta: pagination_props.generate), status: :ok
  end

  # GET /:identifier/reports/:id
  def show
    schema = ShowReportSchema.new(request.params)
    realizer = ReportRealizer.new(intent: :show, parameters: schema, headers: request.headers)
    authorize realizer.object
    render json: JSONAPI::Serializer.serialize(realizer.object), status: :ok
  end

  # POST /:identifier/reports
  def create
    schema = CreateReportSchema.new(request.params)
    realizer = ReportRealizer.new(intent: :create, parameters: schema.render, headers: request.headers)
    authorize realizer.object
    realizer.object.save!
    render json: JSONAPI::Serializer.serialize(realizer.object), status: :created
  end

  # PATCH/PUT /:identifier/reports/:id
  def update
    schema = UpdateReportSchema.new(request.params)
    realizer = ReportRealizer.new(intent: :update, parameters: schema, headers: request.headers)
    authorize realizer.object
    realizer.object.save!
    render json: JSONAPI::Serializer.serialize(realizer.object), status: :ok
  end

  # DELETE /:identifier/reports/:id
  def destroy
    schema = ShowReportSchema.new(request.params)
    realizer = ReportRealizer.new(intent: :show, parameters: schema, headers: request.headers)
    authorize realizer.object
    realizer.object.discard!
  end
end
