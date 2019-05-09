class FoldersController < ApplicationController
  before_action :authenticate_user!

  # GET /:identifier/folders
  def index
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Folder, :index?
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
      authorize Folder, :show?
      @folder = Folder.find(params[:id])
      render json: FolderSerializer.new(@folder).serialized_json, status: :ok
    end
  end

  # POST /:identifier/folders
  def create
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Folder, :create?
      @folder = Folder.create!(folder_params)
      render json: FolderSerializer.new(@folder).serialized_json, status: :created
    end
  end

  # PATCH/PUT /:identifier/folders/:id
  def update
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Folder, :update?
      set_folder
      @folder.update!(folder_params)
      render json: FolderSerializer.new(@folder).serialized_json, status: :ok
    end
  end

  # DELETE /:identifier/folders/:id
  def destroy
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Folder, :destroy?
      set_folder
      @folder.discard!
    end
  end

  # PUT /:identifier/folders/:id/restore
  def restore
    Apartment::Tenant.switch(params[:identifier]) do
      set_folder
      @folder.undiscard!
      render json: FolderSerializer.new(@folder).serialized_json, status: :ok
    end
  end

  def content
    Apartment::Tenant.switch(params[:identifier]) do
      folders = Folder.where(parent_id: params[:id] || 0)
      documents = Document.where(folder_id: params[:id] || 0)
      # Save counts so we don't repeat the SQL query later
      folders_count = folders.count
      documents_count = documents.count
      total = folders_count + documents_count
      # Index of first/last item in the combined collection
      first_item = ((current_page - 1) * per_page)
      last_item = first_item + per_page
      content = []
      if first_item >= folders_count
        # If the page doesn't include any Folders
        content = documents.order('id').offset(first_item - folders_count).limit(per_page)
      elsif last_item < folders_count
        # Likewise, if the page doesn't include any Documents...
        content = folders.order('id').offset(first_item).limit(per_page)
      else
        # If the page includes both, get the trailing Folders and combine
        # with as many Documents as needed to fill the page.
        content = folders.order('id').offset(first_item) + documents.order('id').limit(last_item - folders_count)
      end
      # Create pseudo-paginated collection
      pagination_props = PaginationProperties.new(current_page, (total.to_f / per_page).ceil, per_page)
      options = PaginationGenerator.new(request: request, paginated: pagination_props).generate
      render json: FolderContentSerializer.new(content, options).serialized_json, status: :ok
    end
  end

  # GET /:identifier/folders/:id/folders
  def folders
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Folder, :folders?
      set_folder
      folders = @folder.children.order('id').page(current_page).per(per_page)
      options = PaginationGenerator.new(request: request, paginated: folders).generate
      render json: FolderSerializer.new(folders, options).serialized_json, status: :ok
    end
  end

  # POST /:identifier/folders/:id/folders
  def add_folder
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Folder, :create?
      authorize Folder, :add_folder?
      set_folder
      # For this path, disallow parent_folder param
      new_folder = @folder.children.create!(params.permit(:name))
      render json: FolderSerializer.new(new_folder).serialized_json, status: :created
    end
  end

  # GET /:identifier/folders/:id/documents
  def documents
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Document, :index?
      authorize Folder, :documents?
      set_folder
      documents = @folder.documents.order('id').page(current_page).per(per_page)
      options = PaginationGenerator.new(request: request, paginated: documents).generate
      render json: DocumentSerializer.new(documents, options).serialized_json, status: :ok
    end
  end

  # POST /:identifier/folders/:id/documents
  def add_document
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Document, :create?
      authorize Folder, :add_document?
      set_folder
      document = @folder.documents.create!(params.permit(:content))
      render json: DocumentSerializer.new(document).serialized_json, status: :created
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
