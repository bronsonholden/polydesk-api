require 'json'

class DocumentsController < ApplicationController
  # User must be authenticated before they can interact with documents
  before_action :authenticate_user!

  # POST /:identifier/documents
  def create
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Document, :create?
      realizer = DocumentRealizer.new(intent: :create, parameters: params, headers: request.headers)
      realizer.object.create!
      render json: JSONAPI::Serializer.serialize(realizer.object), status: :created
    end
  end

  # PATCH/PUT /:identifier/documents/:id
  def update
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Document, :update?
      realizer = DocumentRealizer.new(intent: :update, parameters: params, headers: request.headers)
      render json: JSONAPI::Serializer.serialize(realizer.object), status: :created
    end
  end

  # POST /:identifier/documents/:id
  def show
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Document, :show?
      realizer = DocumentRealizer.new(intent: :show, parameters: params, headers: request.headers)
      render json: JSONAPI::Serializer.serialize(realizer.object), status: :ok
    end
  end

  # GET /:identifier/documents
  def index
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Document, :index?
      realizer = DocumentRealizer.new(intent: :index, parameters: params, headers: request.headers)
      documents = realizer.object
      render json: JSONAPI::Serializer.serialize(realizer.object, is_collection: true, meta: { page_offset: page_offset, page_limit: page_limit }), status: :ok
    end
  end

  # DELETE /:identifier/documents/:id
  def destroy
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Document, :destroy?
      realizer = DocumentRealizer.new(intent: :show, parameters: params, headers: request.headers)
      realizer.object.discard!
    end
  end

  # PUT /:identifier/documents/:id/restore
  def restore
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Document, :update?
      realizer = DocumentRealizer.new(intent: :show, parameters: params, headers: request.headers)
      realizer.object.undiscard!
      render json: DocumentSerializer.new(realizer.object).serialized_json, status: :ok
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
      realizer = DocumentRealizer.new(intent: :show, parameters: params, headers: request.headers)
      serve_content(realizer.object)
    end
  end

  # GET /:identifier/documents/:id/versions/:version/download
  def download_version
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Document, :show?
      realizer = DocumentRealizer.new(intent: :show, parameters: params, headers: request.headers)
      version = realizer.object.versions.find(params[:version])
      serve_content(version.reify)
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
