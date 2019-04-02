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
        render json: DocumentSerializer.new(@document).serialized_json, status: :created
      else
        render json: ErrorSerializer.new(@document.errors).serialized_json, status: :unprocessable_entity
      end
    end
  end

  # POST /:identifier/documents/:id
  def show
    Apartment::Tenant.switch(params[:identifier]) do
      @document = Document.find_by_id(params[:id])
      if @document
        authorize @document
        render json: DocumentSerializer.new(@document).serialized_json, status: :ok
      else
        @document = Document.new
        @document.errors.add('document', 'does not exist')
        render json: ErrorSerializer.new(@document.errors).serialized_json, status: :not_found
      end
    end
  end

  # GET /:identifier/documents
  def index
    Apartment::Tenant.switch(params[:identifier]) do
      if params.key?(:root) && params[:root] == 'true' then
        @documents = Document.left_outer_joins(:folder)
                             .where(folders: { id: nil })
                             .references(:folders)
      else
        @documents = Document.all
      end

      authorize @documents

      @documents = @documents.page(current_page).per(per_page)
      options = PaginationGenerator.new(request: request, paginated: @documents).generate

      render json: DocumentSerializer.new(@documents, options).serialized_json, status: :ok
    end
  end

  # GET /:identifier/documents/:id/folder
  def folder
    Apartment::Tenant.switch(params[:identifier]) do
      @document = Document.find_by_id(params[:id])
      if @document
        authorize @document
        render json: FolderSerializer.new(@document.folder).serialized_json, status: :ok
      else
        @document = Document.new
        @document.errors.add('document', 'does not exist')
        render json: ErrorSerializer.new(@document.errors).serialized_json, status: :not_found
      end
    end
  end

  private
    def document_params
      params.permit(:content)
    end
end
