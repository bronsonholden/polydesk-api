class FormsController < ApplicationController
  # GET /:identifier/forms
  def index
    Apartment::Tenant.switch(params['identifier']) do
      authorize Form, :index?
      @forms = Form.all.order('id').page(current_page).per(per_page)
      options = PaginationGenerator.new(request: request, paginated: @forms).generate
      render json: FormSerializer.new(@forms, options).serialized_json, status: :ok
    end
  end

  # GET /:identifier/forms/:id
  def show
    Apartment::Tenant.switch(params['identifier']) do
      authorize Form, :show?
      set_form
      render json: FormSerializer.new(@forms).serialized_json, status: :ok
    end
  end

  # POST /:identifier/forms
  def create
    Apartment::Tenant.switch(params['identifier']) do
      authorize Form, :create?
      @form = Form.new(form_params)
      if @form.save
        render json: FormSerializer.new(@form).serialized_json, status: :created
      else
        render json: @form.errors, status: :unprocessable_entity
      end
    end
  end

  # PATCH/PUT /:identifier/forms/:id
  def update
    Apartment::Tenant.switch(params['identifier']) do
      authorize Form, :update?
      set_form
      if @form.update(form_params)
        render json: FormSerializer.new(@form).serialized_json, status: :ok
      else
        render json: @form.errors, status: :unprocessable_entity
      end
    end
  end

  # DELETE /:identifier/forms/:id
  def destroy
    Apartment::Tenant.switch(params['identifier']) do
      authorize Form, :destroy?
      set_form
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
      params.permit(:name, schema: {}, layout: {})
    end
end
