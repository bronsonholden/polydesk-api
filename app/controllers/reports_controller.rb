class ReportsController < ApplicationController
  before_action :set_report, only: [:show, :update, :destroy]

  # GET /:identifier/reports
  def index
    @reports = Report.all

    render json: @reports
  end

  # GET /:identifier/reports/:id
  def show
    render json: @report
  end

  # POST /:identifier/reports
  def create
    @report = Report.new(report_params)

    if @report.save
      render json: @report, status: :created, location: @report
    else
      render json: ErrorSerializer.new(@report.errors).serialized_json, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /:identifier/reports/:id
  def update
    if @report.update(report_params)
      render json: @report
    else
      render json: ErrorSerializer.new(@report.errors).serialized_json, status: :unprocessable_entity
    end
  end

  # DELETE /:identifier/reports/:id
  def destroy
    @report.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_report
      @report = Report.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def report_params
      params.fetch(:report, {})
    end
end
