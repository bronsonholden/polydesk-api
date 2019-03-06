class FoldersController < ApplicationController
  # GET /:identifier/folders
  def index
    Apartment::Tenant.switch(params[:identifier]) do
      if params.key?(:root) && params[:root] == 'true' then
        @folders = Folder.where(parent_id: 0)
      else
        @folders = Folder.all
      end

      render json: FolderSerializer.new(@folders).serialized_json
    end
  end

  # GET /:identifier/folders/:id
  def show
    Apartment::Tenant.switch(params[:identifier]) do
      set_folder
      render json: FolderSerializer.new(@folder).serialized_json
    end
  end

  # POST /:identifier/folders
  def create
    Apartment::Tenant.switch(params[:identifier]) do
      @folder = Folder.new(folder_params)

      if @folder.save
        render json: FolderSerializer.new(@folder).serialized_json, status: :created
      else
        render json: @folder.errors, status: :unprocessable_entity
      end
    end
  end

  # PATCH/PUT /:identifier/folders/:id
  def update
    Apartment::Tenant.switch(params[:identifier]) do
      set_folder
      if @folder.update(folder_params)
        render json: FolderSerializer.new(@folder).serialized_json
      else
        render json: @folder.errors, status: :unprocessable_entity
      end
    end
  end

  # DELETE /:identifier/folders/:id
  def destroy
    Apartment::Tenant.switch(params[:identifier]) do
      set_folder
      @folder.destroy
    end
  end

  # GET /:identifier/folders/:id/folders
  def children
    Apartment::Tenant.switch(params[:identifier]) do
      set_folder
      render json: FolderSerializer.new(@folder.children).serialized_json
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
        render json: new_folder.errors, status: :unprocessable_entity
      end
    end
  end

  # GET /:identifier/folders/:id/documents
  def documents
    Apartment::Tenant.switch(params[:identifier]) do
      set_folder
      render json: DocumentSerializer.new(@folder.documents).serialized_json
    end
  end

  # POST /:identifier/folders/:id/documents
  def add_document
    Apartment::Tenant.switch(params[:identifier]) do
      set_folder
      document = @folder.documents.create(params.permit(:content))
      if document.save
        render json: DocumentSerializer.new(document).serialized_json, status: :created
      else
        render json: document.errors, status: :unprocessable_entity
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
