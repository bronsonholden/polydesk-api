require 'json'

class DocumentsController < ApplicationController
  include StrongerParameters::ControllerSupport::PermittedParameters

  permitted_parameters :all, { identifier: Parameters.string, data: {}, document: {} }
  permitted_parameters :index, {}
  permitted_parameters :create, { data: {
                                    type: Parameters.enum('document'),
                                    attributes: {
                                      name: Parameters.string,
                                      content: Parameters.file } } }
  permitted_parameters :update, { id: Parameters. id,
                                  data: {
                                    id: Parameters.id,
                                    type: Parameters.enum('document'),
                                    attributes: {
                                      name: Parameters.string,
                                      content: Parameters.file } } }
  permitted_parameters :show, { id: Parameters.id }
  permitted_parameters :destroy, { id: Parameters.id }
  permitted_parameters :restore, { id: Parameters.id }
  permitted_parameters :download, { id: Parameters.id }
  permitted_parameters :download_version, { id: Parameters.id, version: Parameters.id }

  # User must be authenticated before they can interact with documents
  before_action :authenticate_user!

  # POST /:identifier/documents
  def create
    validate_params! :create
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Document, :create?
      @document = Document.create!(attribute_params)
      render json: DocumentSerializer.new(@document).serialized_json, status: :created
    end
  end

  # PATCH/PUT /:identifier/documents/:id
  def update
    validate_params! :update
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Document, :update?
      @document = Document.find(params[:id])
      @document.update!(attribute_params)
      render json: DocumentSerializer.new(@document).serialized_json, status: :ok
    end
  end

  # POST /:identifier/documents/:id
  def show
    validate_params! :read
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Document, :show?
      @document = Document.find(params[:id])
      render json: DocumentSerializer.new(@document).serialized_json, status: :ok
    end
  end

  # GET /:identifier/documents
  def index
    validate_params! :read
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Document, :index?

      if params.key?(:root) && params[:root] == 'true' then
        @documents = Document.left_outer_joins(:folder)
                             .where(folders: { id: nil })
                             .references(:folders)
      else
        @documents = Document.all
      end

      @documents = @documents.order('id').page(current_page).per(per_page)
      options = PaginationGenerator.new(request: request, paginated: @documents).generate

      render json: DocumentSerializer.new(@documents, options).serialized_json, status: :ok
    end
  end

  # DELETE /:identifier/documents/:id
  def destroy
    validate_params! :read
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Document, :destroy?
      @document = Document.find(params[:id])
      @document.discard!
    end
  end

  # PUT /:identifier/documents/:id/restore
  def restore
    validate_params! :read
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Document, :update?
      @document = Document.find(params[:id])
      @document.undiscard!
      render json: DocumentSerializer.new(@document.reload).serialized_json, status: :ok
    end
  end

  # GET /:identifier/documents/:id/folder
  def folder
    validate_params! :read
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Document, :show?
      authorize Folder, :show?

      @document = Document.find(params[:id])
      folder_json = FolderSerializer.new(@document.folder).serialized_json

      if @document.folder.nil?
        folder_json = { data: [] }
      end

      render json: folder_json, status: :ok
    end
  end

  # GET /:identifier/documents/:id/download
  def download
    validate_params! :read
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Document, :show?
      @document = Document.find(params[:id])
      serve_content(@document)
    end
  end

  # GET /:identifier/documents/:id/versions/:version/download
  def download_version
    validate_params! :read
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Document, :show?
      @document = Document.find(params[:id])
      @version = @document.versions.find(params[:version])
      serve_content(@version.reify)
    end
  end

  private
    def serve_content(document)
      storage = document.content.storage
      if storage.instance_of? Shrine::Storage::FileSystem
        send_file ['storage', document.content_url].join
      elsif storage.instance_of? Shrine::Storage::S3
        redirect_to document.content_url
      else
        render nothing: true, status: :not_found
      end
    end
end
