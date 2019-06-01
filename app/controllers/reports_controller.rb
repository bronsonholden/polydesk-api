class ReportsController < ApplicationController
  before_action :authenticate_user!

  # GET /:identifier/reports
  def index
    authorize Report, :index?
    schema = IndexReportsSchema.new(request.params)
    realizer = ReportRealizer.new(intent: :index, parameters: schema, headers: request.headers)
    pagination_props = PaginationProperties.new(page_offset, page_limit, realizer.object.size)
    render json: JSONAPI::Serializer.serialize(realizer.object, is_collection: true, meta: pagination_props), status: :ok
  end

  # GET /:identifier/reports/:id
  def show
    authorize Report, :show?
    schema = ShowReportSchema.new(request.params)
    realizer = ReportRealizer.new(intent: :show, parameters: schema, headers: request.headers)
    render json: JSONAPI::Serializer.serialize(realizer.object), status: :ok
  end

  # POST /:identifier/reports
  def create
    authorize Report, :create?
    schema = CreateReportSchema.new(request.params)
    realizer = ReportRealizer.new(intent: :create, parameters: schema, headers: request.headers)
    realizer.object.save!
    render json: JSONAPI::Serializer.serialize(realizer.object), status: :created
  end

  # PATCH/PUT /:identifier/reports/:id
  def update
    authorize Report, :update?
    schema = UpdateReportSchema.new(request.params)
    realizer = ReportRealizer.new(intent: :update, parameters: schema, headers: request.headers)
    realizer.object.save!
    render json: JSONAPI::Serializer.serialize(realizer.object), status: :ok
  end

  # DELETE /:identifier/reports/:id
  def destroy
    authorize Report, :destroy?
    schema = ShowReportSchema.new(request.params)
    realizer = ReportRealizer.new(intent: :show, parameters: schema, headers: request.headers)
    realizer.object.discard!
  end
end
