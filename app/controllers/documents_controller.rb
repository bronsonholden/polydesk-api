require 'json'

class DocumentsController < ApplicationController
  # User must be authenticated before they can interact with documents
  before_action :authenticate_user!

  # POST /:identifier/documents
  def create
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Document, :create?
      @document = Document.create!(document_params)
      render json: JSONAPI::ResourceSerializer.new(DocumentResource).serialize_to_hash(DocumentResource.new(@document, nil)), status: :ok
    end
  end

  # PATCH/PUT /:identifier/documents/:id
  def update
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Document, :update?
      @document = Document.find(params[:id])
      @document.update!(document_params)
      render json: JSONAPI::ResourceSerializer.new(DocumentResource).serialize_to_hash(DocumentResource.new(@document, nil)), status: :ok
    end
  end

  # POST /:identifier/documents/:id
  def show
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Document, :show?
      @document = Document.find(params[:id])
      render json: JSONAPI::ResourceSerializer.new(DocumentResource).serialize_to_hash(DocumentResource.new(@document, nil)), status: :ok
    end
  end

  # GET /:identifier/documents
  def index
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Document, :index?
      @documents = Document.all
      @document_resources = @documents.map { |document| DocumentResource.new(document, nil) }
      render json: JSONAPI::ResourceSerializer.new(DocumentResource).serialize_to_hash(@document_resources), status: :ok
    end
  end

  # DELETE /:identifier/documents/:id
  def destroy
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Document, :destroy?
      @document = Document.find(params[:id])
      @document.discard!
    end
  end

  # PUT /:identifier/documents/:id/restore
  def restore
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Document, :update?
      @document = Document.find(params[:id])
      @document.undiscard!
      render json: DocumentSerializer.new(@document.reload).serialized_json, status: :ok
    end
  end

  # GET /:identifier/documents/:id/folder
  def folder
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
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Document, :show?
      @document = Document.find(params[:id])
      serve_content(@document)
    end
  end

  # GET /:identifier/documents/:id/versions/:version/download
  def download_version
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

    def document_params
      params.permit(:content, :name)
    end
end
