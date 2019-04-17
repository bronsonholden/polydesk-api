class ReportsController < ApplicationController
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
      @report = Report.create!(report_params)
      render json: ReportSerializer.new(@report).serialized_json, status: :created
    end
  end

  # PATCH/PUT /:identifier/reports/:id
  def update
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Report, :update?
      set_report
      @report.update!(report_params)
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
      @report = Report.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def report_params
      params.permit(:name)
    end
end
