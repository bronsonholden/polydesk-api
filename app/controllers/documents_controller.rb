class DocumentsController < ApplicationController
  def new
  end

  def create
    @document = Document.create(document_params)
    if @document.save
      render json: @document, status: :ok
    else
      render json: @document.errors, status: :unprocessable_entity
    end
  end

  def show
    @document = Document.find(params[:id])
    render json: @document, status: :ok
  end

  def index
    @documents = Document.all
    render json: @documents, status: :ok
  end

  def document_params
    params.permit(:content)
  end
end
