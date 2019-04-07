class FoldersController < ApplicationController
  # GET /:identifier/folders
  def index
    Apartment::Tenant.switch(params[:identifier]) do
      if params.key?(:root) && params[:root] == 'true' then
        @folders = Folder.where(parent_id: 0)
      else
        @folders = Folder.all
      end

      @folders = @folders.order('id').page(current_page).per(per_page)
      options = PaginationGenerator.new(request: request, paginated: @folders).generate

      render json: FolderSerializer.new(@folders, options).serialized_json, status: :ok
    end
  end

  # GET /:identifier/folders/:id
  def show
    Apartment::Tenant.switch(params[:identifier]) do
      @folder = Folder.find_by_id(params[:id])
      if @folder
        render json: FolderSerializer.new(@folder).serialized_json, status: :ok
      else
        @folder = Folder.new
        @folder.errors.add('folder', 'does not exist')
        render json: ErrorSerializer.new(@folder.errors).serialized_json, status: :not_found
      end
    end
  end

  # POST /:identifier/folders
  def create
    Apartment::Tenant.switch(params[:identifier]) do
      @folder = Folder.new(folder_params)

      if @folder.save!
        render json: FolderSerializer.new(@folder).serialized_json, status: :created
      end
    end
  end

  # PATCH/PUT /:identifier/folders/:id
  def update
    Apartment::Tenant.switch(params[:identifier]) do
      set_folder
      if @folder.update(folder_params)
        render json: FolderSerializer.new(@folder).serialized_json, status: :ok
      else
        render json: ErrorSerializer.new(@folder.errors).serialized_json, status: :unprocessable_entity
      end
    end
  end

  # DELETE /:identifier/folders/:id
  def destroy
    Apartment::Tenant.switch(params[:identifier]) do
      set_folder
      @folder.destroy

      render json: {}, status: :ok
    end
  end

  # GET /:identifier/folders/:id/folders
  def children
    Apartment::Tenant.switch(params[:identifier]) do
      set_folder
      children = @folder.children.order('id').page(current_page).per(per_page)
      options = PaginationGenerator.new(request: request, paginated: children).generate
      render json: FolderSerializer.new(children, options).serialized_json, status: :ok
    end
  end

  # POST /:identifier/folders/:id/folders
  def add_folder
    Apartment::Tenant.switch(params[:identifier]) do
      set_folder
      # For this path, disallow parent_folder param
      new_folder = @folder.children.create(params.permit(:name))
      if new_folder.save
        render json: FolderSerializer.new(new_folder).serialized_json, status: :created
      else
        render json: ErrorSerializer.new(new_folder.errors).serialized_json, status: :unprocessable_entity
      end
    end
  end

  # GET /:identifier/folders/:id/documents
  def documents
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Document, :index?
      set_folder
      documents = @folder.documents.order('id').page(current_page).per(per_page)
      options = PaginationGenerator.new(request: request, paginated: documents).generate
      render json: DocumentSerializer.new(documents, options).serialized_json, status: :ok
    end
  end

  # POST /:identifier/folders/:id/documents
  def add_document
    Apartment::Tenant.switch(params[:identifier]) do
      set_folder
      document = @folder.documents.new(params.permit(:content))
      authorize document, :create?, policy_class: DocumentPolicy
      if document.save
        render json: DocumentSerializer.new(document).serialized_json, status: :created
      else
        render json: ErrorSerializer.new(document.errors).serialized_json, status: :unprocessable_entity
      end
    end
  end

  private
    def set_folder
      @folder = Folder.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def folder_params
      params.permit(:name, :parent_folder)
    end
end
