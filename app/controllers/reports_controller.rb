class ReportsController < ApplicationController
  # GET /:identifier/reports
  def index
    Apartment::Tenant.switch(params[:identifier]) do
      @reports = Report.all.order('id').page(current_page).per(per_page)
      options = PaginationGenerator.new(request: request, paginated: @reports).generate

      render json: ReportSerializer.new(@reports, options).serialized_json, status: :ok
    end
  end

  # GET /:identifier/reports/:id
  def show
    Apartment::Tenant.switch(params[:identifier]) do
      set_report
      render json: ReportSerializer.new(@report).serialized_json, status: :ok
    end
  end

  # POST /:identifier/reports
  def create
    Apartment::Tenant.switch(params[:identifier]) do
      @report = Report.new(report_params)

      if @report.save
        render json: ReportSerializer.new(@report).serialized_json, status: :created
      else
        render json: ErrorSerializer.new(@report.errors).serialized_json, status: :unprocessable_entity
      end
    end
  end

  # PATCH/PUT /:identifier/reports/:id
  def update
    Apartment::Tenant.switch(params[:identifier]) do
      set_report
      if @report.update(report_params)
        render json: ReportSerializer.new(@report).serialized_json, status: :ok
      else
        render json: ErrorSerializer.new(@report.errors).serialized_json, status: :unprocessable_entity
      end
    end
  end

  # DELETE /:identifier/reports/:id
  def destroy
    Apartment::Tenant.switch(params[:identifier]) do
      set_report
      @report.destroy

      render json: {}, status: :ok
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
