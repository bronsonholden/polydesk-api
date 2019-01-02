class DocumentsController < ApplicationController
  # User must be authenticated before they can interact with documents
  before_action :authenticate_user!

  def new
  end

  # POST /:identifier/documents
  def create
    Apartment::Tenant.switch(params[:identifier]) do
      @document = Document.new(document_params)
      authorize @document
      if @document.save
        render json: @document, status: :ok
      else
        render json: @document.errors, status: :unprocessable_entity
      end
    end
  end

  # POST /:identifier/documents/:id
  def show
    Apartment::Tenant.switch(params[:identifier]) do
      @document = Document.find(params[:id])
      authorize @document
      render json: @document, status: :ok
    end
  end

  # GET /:identifier/documents
  def index
    Apartment::Tenant.switch(params[:identifier]) do
      @documents = Document.all
      render json: @documents, status: :ok
    end
  end

  private
    def document_params
      params.permit(:content)
    end
end
