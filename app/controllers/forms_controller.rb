class FormsController < ApplicationController
  before_action :authenticate_account!

  # POST /:identifier/forms
  def create
    Apartment::Tenant.switch(params['identifier']) do
      authorize Form, :create?
      schema = CreateFormSchema.new(request.params)
      realizer = FormRealizer.new(intent: :create, parameters: schema, headers: request.headers)
      realizer.object.save!
      render json: JSONAPI::Serializer.serialize(realizer.object), status: :created
    end
  end

  # GET /:identifier/forms
  def index
    Apartment::Tenant.switch(params['identifier']) do
      authorize Form, :index?
      schema = IndexFormsSchema.new(request.params)
      realizer = FormRealizer.new(intent: :index, parameters: schema, headers: request.headers)
      render json: JSONAPI::Serializer.serialize(realizer.object, is_collection: true), status: :ok
    end
  end

  # GET /:identifier/forms/:id
  def show
    Apartment::Tenant.switch(params['identifier']) do
      authorize Form, :show?
      schema = ShowFormSchema.new(request.params)
      realizer = FormRealizer.new(intent: :show, parameters: schema, headers: request.headers)
      render json: JSONAPI::Serializer.serialize(realizer.object), status: :ok
    end
  end

  # PATCH/PUT /:identifier/forms/:id
  def update
    Apartment::Tenant.switch(params['identifier']) do
      authorize Form, :update?
      schema = UpdateFormSchema.new(request.params)
      realizer = FormRealizer.new(intent: :update, parameters: schema, headers: request.headers)
      realizer.object.save!
      render json: JSONAPI::Serializer.serialize(realizer.object), status: :ok
    end
  end

  # DELETE /:identifier/forms/:id
  def destroy
    Apartment::Tenant.switch(params['identifier']) do
      authorize Form, :destroy?
      schema = ShowFormSchema.new(request.params)
      realizer = FormRealizer.new(intent: :show, parameters: schema, headers: request.headers)
      realizer.object.destroy
    end
  end
end
