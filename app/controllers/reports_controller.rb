class ReportsController < ApplicationController
  include StrongerParameters::ControllerSupport::PermittedParameters

  permitted_parameters :all, { identifier: Parameters.string }
  permitted_parameters :index, {}
  permitted_parameters :show, { id: Parameters.id }
  permitted_parameters :create, { name: Parameters.string }
  permitted_parameters :update, { id: Parameters.id, name: Parameters.string }
  permitted_parameters :destroy, { id: Parameters.id }

  before_action :authenticate_user!

  # GET /:identifier/reports
  def index
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Report, :index?
      @reports = Report.all.order('id').page(current_page).per(per_page)
      options = PaginationGenerator.new(request: request, paginated: @reports).generate

      render json: ReportSerializer.new(@reports, options).serialized_json, status: :ok
    end
  end

  # GET /:identifier/reports/:id
  def show
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Report, :show?
      set_report
      render json: ReportSerializer.new(@report).serialized_json, status: :ok
    end
  end

  # POST /:identifier/reports
  def create
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Report, :create?
      @report = Report.create!(permitted_params)
      render json: ReportSerializer.new(@report).serialized_json, status: :created
    end
  end

  # PATCH/PUT /:identifier/reports/:id
  def update
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Report, :update?
      set_report
      @report.update!(permitted_params)
      render json: ReportSerializer.new(@report).serialized_json, status: :ok
    end
  end

  # DELETE /:identifier/reports/:id
  def destroy
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Report, :destroy?
      set_report
      @report.destroy
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_report
      @report = Report.find(permitted_params.fetch(id))
    end
end
