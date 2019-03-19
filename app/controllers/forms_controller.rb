class FormsController < ApplicationController
  before_action :set_form, only: [:show, :update, :destroy]

  # GET /:identifier/forms
  def index
    Apartment::Tenant.switch(params['identifier']) do
      @forms = Form.all

      render json: FormSerializer.new(@forms).serialized_json, status: :ok
    end
  end

  # GET /:identifier/forms/1
  def show
    Apartment::Tenant.switch(params['identifier']) do
      render json: FormSerializer.new(@forms).serialized_json, status: :ok
    end
  end

  # POST /:identifier/forms
  def create
    Apartment::Tenant.switch(params['identifier']) do
      @form = Form.new(form_params)

      if @form.save
        render json: FormSerializer.new(@form).serialized_json, status: :created
      else
        render json: @form.errors, status: :unprocessable_entity
      end
    end
  end

  # PATCH/PUT /:identifier/forms/1
  def update
    Apartment::Tenant.switch(params['identifier']) do
      if @form.update(form_params)
        render json: FormSerializer.new(@form).serialized_json, status: :ok
      else
        render json: @form.errors, status: :unprocessable_entity
      end
    end
  end

  # DELETE /:identifier/forms/1
  def destroy
    Apartment::Tenant.switch(params['identifier']) do
      @form.destroy
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_form
      Apartment::Tenant.switch(params['identifier']) do
        @form = Form.find(params[:id])
      end
    end

    # Only allow a trusted parameter "white list" through.
    def form_params
      params.permit(:name)
    end
end
