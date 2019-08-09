class FoldersController < ApplicationController
  before_action :authenticate_user!

  # GET /:identifier/folders
  def index
    schema = IndexFoldersSchema.new(request.params)
    scope = policy_scope(Folder)
    realizer = FolderRealizer.new(intent: :index, parameters: schema, headers: request.headers, scope: scope)
    authorize realizer.object
    pagination_props = PaginationProperties.new(page_offset, page_limit, realizer.total_count)
    render json: JSONAPI::Serializer.serialize(realizer.object, is_collection: true, include: (schema.include.split(',') if schema.key?('include')), meta: pagination_props.generate), status: :ok
  end

  # GET /:identifier/folders/:id
  def show
    schema = ShowFolderSchema.new(request.params)
    realizer = FolderRealizer.new(intent: :show, parameters: schema, headers: request.headers)
    authorize realizer.object
    render json: JSONAPI::Serializer.serialize(realizer.object, include: (schema.include.split(',') if schema.key?('include'))), status: :ok
  end

  # POST /:identifier/folders
  def create
    schema = CreateFolderSchema.new(request.params)
    payload = sanitize_payload(schema.render, Folder)
    realizer = FolderRealizer.new(intent: :create, parameters: payload, headers: request.headers)
    authorize realizer.object
    realizer.object.save!
    render json: JSONAPI::Serializer.serialize(realizer.object), status: :created
  end

  # PATCH/PUT /:identifier/folders/:id
  def update
    schema = UpdateFolderSchema.new(request.params)
    payload = sanitize_payload(schema.render, Folder)
    realizer = FolderRealizer.new(intent: :update, parameters: payload, headers: request.headers)
    authorize realizer.object
    realizer.object.save!
    render json: JSONAPI::Serializer.serialize(realizer.object), status: :ok
  end

  # DELETE /:identifier/folders/:id
  def destroy
    schema = ShowFolderSchema.new(request.params)
    realizer = FolderRealizer.new(intent: :show, parameters: schema, headers: request.headers)
    authorize realizer.object
    realizer.object.discard!
  end

  # PUT /:identifier/folders/:id/restore
  def restore
    schema = ShowFolderSchema.new(request.params)
    realizer = FolderRealizer.new(intent: :show, parameters: schema, headers: request.headers)
    authorize realizer.object, :restore?
    realizer.object.undiscard!
    render json: JSONAPI::Serializer.serialize(realizer.object.reload), status: :ok
  end

  def content
    folder_id = params[:id]
    if !folder_id.nil?
      folder = Folder.find(folder_id)
      authorize folder, :folders?
      authorize folder, :documents?
    end
    folders = Folder.kept.where(folder_id: params[:id] || 0)
    authorize folders, :index?
    documents = Document.kept.where(folder_id: params[:id] || 0)
    authorize documents, :index?
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
    pagination_props = PaginationProperties.new(page_offset, page_limit, total)
    render json: JSONAPI::Serializer.serialize(content, is_collection: true, meta: pagination_props.generate), status: :ok
  end

  # GET /:identifier/folders/:id/folders
  def folders
    schema = ShowFolderSchema.new(request.params)
    realizer = FolderRealizer.new(intent: :show, parameters: schema, headers: request.headers)
    authorize realizer.object
    pagination_props = PaginationProperties.new(page_offset, page_limit, realizer.object.folders.size)
    render json: JSONAPI::Serializer.serialize(realizer.object.folders, is_collection: true, meta: pagination_props.generate), status: :ok
  end

  # GET /:identifier/folders/:id/documents
  def documents
    schema = ShowFolderSchema.new(request.params)
    realizer = FolderRealizer.new(intent: :show, parameters: schema, headers: request.headers)
    authorize realizer.object, :documents?
    authorize realizer.object.documents, :index?
    pagination_props = PaginationProperties.new(page_offset, page_limit, realizer.object.documents.size)
    render json: JSONAPI::Serializer.serialize(realizer.object.documents, is_collection: true, meta: pagination_props.generate), status: :ok
  end

  # Non-JSON:API document create
  def upload_document
    folder = Folder.find(params.permit(:id).fetch(:id))
    authorize folder, :update?
    document = folder.documents.create(params.permit(:content, :name))
    authorize document, :create?
    document.save!
    render json: JSONAPI::Serializer.serialize(document), status: :created
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
