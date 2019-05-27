class ReportsController < ApplicationController
  before_action :authenticate_account!

  # GET /:identifier/reports
  def index
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Report, :index?
      schema = IndexReportsSchema.new(request.params)
      realizer = ReportRealizer.new(intent: :index, parameters: schema, headers: request.headers)
      render json: JSONAPI::Serializer.serialize(realizer.object, is_collection: true), status: :ok
    end
  end

  # GET /:identifier/reports/:id
  def show
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Report, :show?
      schema = ShowReportSchema.new(request.params)
      realizer = ReportRealizer.new(intent: :show, parameters: schema, headers: request.headers)
      render json: JSONAPI::Serializer.serialize(realizer.object), status: :ok
    end
  end

  # POST /:identifier/reports
  def create
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Report, :create?
      schema = CreateReportSchema.new(request.params)
      realizer = ReportRealizer.new(intent: :create, parameters: schema, headers: request.headers)
      realizer.object.save!
      render json: JSONAPI::Serializer.serialize(realizer.object), status: :ok
    end
  end

  # PATCH/PUT /:identifier/reports/:id
  def update
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Report, :update?
      schema = UpdateReportSchema.new(request.params)
      realizer = ReportRealizer.new(intent: :update, parameters: schema, headers: request.headers)
      realizer.object.save!
      render json: JSONAPI::Serializer.serialize(realizer.object), status: :ok
    end
  end

  # DELETE /:identifier/reports/:id
  def destroy
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Report, :destroy?
      schema = ShowReportSchema.new(request.params)
      realizer = ReportRealizer.new(intent: :show, parameters: schema, headers: request.headers)
      realizer.object.discard!
    end
  end
end
