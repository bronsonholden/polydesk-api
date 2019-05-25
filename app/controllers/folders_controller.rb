class FoldersController < ApplicationController
  before_action :authenticate_user!

  # GET /:identifier/folders
  def index
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Folder, :index?
      realizer = FolderRealizer.new(intent: :index, parameters: params, headers: request.headers)
      render json: JSONAPI::Serializer.serialize(realizer.object, is_collection: true), status: :ok
    end
  end

  # GET /:identifier/folders/:id
  def show
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Folder, :show?
      realizer = FolderRealizer.new(intent: :show, parameters: params, headers: request.headers)
      render json: JSONAPI::Serializer.serialize(realizer.object), status: :ok
    end
  end

  # POST /:identifier/folders
  def create
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Folder, :create?
      realizer = FolderRealizer.new(intent: :create, parameters: params, headers: request.headers)
      realizer.object.create!
      render json: JSONAPI::Serializer.serialize(realizer.object), status: :created
    end
  end

  # PATCH/PUT /:identifier/folders/:id
  def update
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Folder, :update?
      realizer = FolderRealizer.new(intent: :create, parameters: params.require(:data).permit(:id), headers: request.headers)
      realizer.object.update!(params.require(:data).permit(attributes: [:name]))
      render json: JSONAPI::Serializer.serialize(realizer.object), status: :ok
    end
  end

  # DELETE /:identifier/folders/:id
  def destroy
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Folder, :destroy?
      realizer = FolderRealizer.new(intent: :show, parameters: params, headers: request.headers)
      realizer.object.discard!
    end
  end

  # PUT /:identifier/folders/:id/restore
  def restore
    Apartment::Tenant.switch(params[:identifier]) do
      realizer = FolderRealizer.new(intent: :show, parameters: params, headers: request.headers)
      realizer.object.undiscard!
      render json: JSONAPI::Serializer.serialize(realizer.object.reload), status: :ok
    end
  end

  def content
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Folder, :folders?
      authorize Folder, :documents?
      folders = Folder.kept.where(parent_id: params[:id] || 0)
      documents = Document.kept.where(folder_id: params[:id] || 0)
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
      options = PaginationGenerator.new(request: request, paginated: pagination_props, count: total).generate
      render json: FolderContentSerializer.new(content, options).serialized_json, status: :ok
    end
  end

  # GET /:identifier/folders/:id/folders
  def folders
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Folder, :folders?
      realizer = FolderRealizer.new(intent: :show, parameters: params.permit(:id), headers: request.headers)
      render json: JSONAPI::Serializer.serialize(realizer.object.folders, is_collection: true), status: :ok
    end
  end

  # POST /:identifier/folders/:id/folders
  def add_folder
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Folder, :create?
      realizer = FolderRealizer.new(intent: :show, parameters: params.permit(:id), headers: request.headers)
      folder = realizer.object.folders.create!(params.require(:data).permit(attributes: [:name]))
      render json: JSONAPI::Serializer.serialize(folder), status: :created
    end
  end

  # GET /:identifier/folders/:id/documents
  def documents
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Document, :index?
      authorize Folder, :documents?
      realizer = FolderRealizer.new(intent: :show, parameters: params.permit(:id), headers: request.headers)
      render json: JSONAPI::Serializer.serialize(realizer.object.documents, is_collection: true), status: :ok
    end
  end

  # POST /:identifier/folders/:id/documents
  def add_document
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Document, :create?
      authorize Folder, :add_document?
      realizer = FolderRealizer.new(intent: :show, parameters: params.permit(:id), headers: request.headers)
      document = realizer.object.documents.create!(params.require(:data).permit(attributes: [:name]))
      render json: JSONAPI::Serializer.serialize(document), status: :created
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
