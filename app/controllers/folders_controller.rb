class FoldersController < ApplicationController
  before_action :authenticate_user!

  # GET /:identifier/folders
  def index
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Folder, :index?
      schema = IndexFoldersSchema.new(request.params)
      realizer = FolderRealizer.new(intent: :index, parameters: schema, headers: request.headers)
      render json: JSONAPI::Serializer.serialize(
                     realizer.object,
                     is_collection: true,
                     include: (schema.include.split(',') if schema.key?('include'))
                  ), status: :ok
    end
  end

  # GET /:identifier/folders/:id
  def show
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Folder, :show?
      schema = ShowFolderSchema.new(request.params)
      realizer = FolderRealizer.new(intent: :show, parameters: schema, headers: request.headers)
      render json: JSONAPI::Serializer.serialize(
                     realizer.object,
                     include: (schema.include.split(',') if schema.key?('include'))
                   ), status: :ok
    end
  end

  # POST /:identifier/folders
  def create
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Folder, :create?
      schema = CreateFolderSchema.new(request.params)
      realizer = FolderRealizer.new(intent: :create, parameters: schema, headers: request.headers)
      realizer.object.save!
      render json: JSONAPI::Serializer.serialize(realizer.object), status: :created
    end
  end

  # PATCH/PUT /:identifier/folders/:id
  def update
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Folder, :update?
      schema = UpdateFolderSchema.new(request.params)
      realizer = FolderRealizer.new(intent: :update, parameters: schema, headers: request.headers)
      realizer.object.save!
      render json: JSONAPI::Serializer.serialize(realizer.object), status: :ok
    end
  end

  # DELETE /:identifier/folders/:id
  def destroy
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Folder, :destroy?
      schema = ShowFolderSchema.new(request.params)
      realizer = FolderRealizer.new(intent: :show, parameters: schema, headers: request.headers)
      realizer.object.discard!
    end
  end

  # PUT /:identifier/folders/:id/restore
  def restore
    Apartment::Tenant.switch(params[:identifier]) do
      schema = ShowFolderSchema.new(request.params)
      realizer = FolderRealizer.new(intent: :show, parameters: schema, headers: request.headers)
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
      first_item = (page_offset * page_limit)
      last_item = first_item + page_limit
      content = []
      if first_item >= folders_count
        # If the page doesn't include any Folders
        content = documents.order('id').offset(first_item - folders_count).limit(page_limit)
      elsif last_item < folders_count
        # Likewise, if the page doesn't include any Documents...
        content = folders.order('id').offset(first_item).limit(page_limit)
      else
        # If the page includes both, get the trailing Folders and combine
        # with as many Documents as needed to fill the page.
        content = folders.order('id').offset(first_item) + documents.order('id').limit(last_item - folders_count)
      end
      # Create pseudo-paginated collection
      pagination_props = PaginationProperties.new(page_offset, page_limit, total, (total.to_f / page_limit).ceil)
      render json: JSONAPI::Serializer.serialize(content, is_collection: true, meta: pagination_props), status: :ok
    end
  end

  # GET /:identifier/folders/:id/folders
  def folders
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Folder, :folders?
      schema = ShowFolderSchema.new(request.params)
      realizer = FolderRealizer.new(intent: :show, parameters: schema, headers: request.headers)
      render json: JSONAPI::Serializer.serialize(realizer.object.children, is_collection: true), status: :ok
    end
  end

  # GET /:identifier/folders/:id/documents
  def documents
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Document, :index?
      authorize Folder, :documents?
      schema = ShowFolderSchema.new(request.params)
      realizer = FolderRealizer.new(intent: :show, parameters: schema, headers: request.headers)
      render json: JSONAPI::Serializer.serialize(realizer.object.documents, is_collection: true), status: :ok
    end
  end

  # Non-JSON:API document create
  def upload_document
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Document, :create?
      authorize Folder, :update?
      folder = Folder.find(params.permit(:id).fetch(:id))
      document = folder.documents.create!(params.permit(:content, :name))
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
