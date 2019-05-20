class FoldersController < ApplicationController
  include StrongerParameters::ControllerSupport::PermittedParameters

  permitted_parameters :all, { identifier: Parameters.string, folder: {} }
  permitted_parameters :index, { root: Parameters.boolean }
  permitted_parameters :show, { id: Parameters.id }
  permitted_parameters :create, { data: {
                                    type: Parameters.enum('folder'),
                                    attributes: {
                                      name: Parameters.string,
                                      parent_id: Parameters.id } } }
  permitted_parameters :update, { id: Parameters.id,
                                  data: {
                                    id: Parameters.id,
                                    type: Parameters.enum('folder'),
                                    attributes: {
                                      name: Parameters.string } } }
  permitted_parameters :destroy, { id: Parameters.id }
  permitted_parameters :restore, { id: Parameters.id }
  permitted_parameters :content, { id: Parameters.id }
  permitted_parameters :folders, { id: Parameters.id }
  permitted_parameters :documents, { id: Parameters.id }
  permitted_parameters :add_folder, { id: Parameters.id,
                                      data: {
                                        type: Parameters.enum('folder'),
                                        attributes: {
                                          name: Parameters.string } } }
  permitted_parameters :add_document, { id: Parameters.id,
                                        data: {
                                          type: Parameters.enum('document'),
                                          attributes: {
                                            name: Parameters.string,
                                            content: Parameters.file } } }

  before_action :authenticate_user!

  # GET /:identifier/folders
  def index
    validate_params! :read
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Folder, :index?
      if params.fetch(:root, false) then
        @folders = Folder.kept.where(parent_id: 0)
      else
        @folders = Folder.kept
      end

      @folders = @folders.order('id').page(current_page).per(per_page)
      options = PaginationGenerator.new(request: request, paginated: @folders).generate

      render json: FolderSerializer.new(@folders, options).serialized_json, status: :ok
    end
  end

  # GET /:identifier/folders/:id
  def show
    validate_params! :read
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Folder, :show?
      @folder = Folder.kept.find(permitted_params.fetch(:id))
      render json: FolderSerializer.new(@folder).serialized_json, status: :ok
    end
  end

  # POST /:identifier/folders
  def create
    validate_params! :create
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Folder, :create?
      @folder = Folder.create!(attribute_params)
      render json: FolderSerializer.new(@folder).serialized_json, status: :created
    end
  end

  # PATCH/PUT /:identifier/folders/:id
  def update
    validate_params! :update
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Folder, :update?
      set_folder
      @folder.update!(attribute_params)
      render json: FolderSerializer.new(@folder).serialized_json, status: :ok
    end
  end

  # DELETE /:identifier/folders/:id
  def destroy
    validate_params! :read
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Folder, :destroy?
      set_folder
      @folder.discard!
    end
  end

  # PUT /:identifier/folders/:id/restore
  def restore
    validate_params! :read
    Apartment::Tenant.switch(params[:identifier]) do
      set_folder
      @folder.undiscard!
      render json: FolderSerializer.new(@folder).serialized_json, status: :ok
    end
  end

  def content
    validate_params! :read
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Folder, :folders?
      authorize Folder, :documents?
      folder_id = permitted_params.fetch(:id, 0)
      folders = Folder.kept.where(parent_id: folder_id)
      documents = Document.kept.where(folder_id: folder_id)
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
    validate_params! :read
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Folder, :folders?
      set_folder
      folders = @folder.children.kept.order('id').page(current_page).per(per_page)
      options = PaginationGenerator.new(request: request, paginated: folders).generate
      render json: FolderSerializer.new(folders, options).serialized_json, status: :ok
    end
  end

  # POST /:identifier/folders/:id/folders
  def add_folder
    validate_params! :read
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Folder, :create?
      authorize Folder, :add_folder?
      set_folder
      # For this path, disallow parent_folder param
      new_folder = @folder.children.create!(attribute_params.except(:parent_id))
      render json: FolderSerializer.new(new_folder).serialized_json, status: :created
    end
  end

  # GET /:identifier/folders/:id/documents
  def documents
    validate_params! :read
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Document, :index?
      authorize Folder, :documents?
      set_folder
      documents = @folder.documents.kept.order('id').page(current_page).per(per_page)
      options = PaginationGenerator.new(request: request, paginated: documents).generate
      render json: DocumentSerializer.new(documents, options).serialized_json, status: :ok
    end
  end

  # POST /:identifier/folders/:id/documents
  def add_document
    validate_params! :read
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Document, :create?
      authorize Folder, :add_document?
      set_folder
      document = @folder.documents.create!(attribute_params)
      render json: DocumentSerializer.new(document).serialized_json, status: :created
    end
  end

  private
    def set_folder
      @folder = Folder.find(permitted_params.fetch(:id))
    end
end
