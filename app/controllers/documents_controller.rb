class DocumentsController < ApplicationController
  # User must be authenticated before they can interact with documents
  before_action :authenticate_user!

  def new
  end

  def create
    Apartment::Tenant.switch(params[:identifier]) do
      @document = Document.create(document_params)
      if @document.save
        render json: @document, status: :ok
      else
        render json: @document.errors, status: :unprocessable_entity
      end
    end
  end

  def show
    Apartment::Tenant.switch(params[:identifier]) do
      @document = Document.find(params[:id])
      render json: @document, status: :ok
    end
  end

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
