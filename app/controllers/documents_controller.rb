require 'json'

class DocumentsController < ApplicationController
  before_action :authenticate_user!

  # POST /:identifier/documents
  def create
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Document, :create?
      puts request.params.inspect
      schema = CreateDocumentSchema.new(request.params)
      realizer = DocumentRealizer.new(intent: :create, parameters: schema, headers: request.headers)
      realizer.object.save!
      render json: JSONAPI::Serializer.serialize(realizer.object), status: :created
    end
  end

  # PATCH/PUT /:identifier/documents/:id
  def update
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Document, :update?
      schema = UpdateDocumentSchema.new (request.params)
      realizer = DocumentRealizer.new(intent: :update, parameters: schema, headers: request.headers)
      realizer.object.save!
      render json: JSONAPI::Serializer.serialize(realizer.object), status: :ok
    end
  end

  # POST /:identifier/documents/:id
  def show
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Document, :show?
      schema = ShowDocumentSchema.new(request.params)
      realizer = DocumentRealizer.new(intent: :show, parameters: schema, headers: request.headers)
      render json: JSONAPI::Serializer.serialize(realizer.object), status: :ok
    end
  end

  # GET /:identifier/documents
  def index
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Document, :index?
      schema = IndexDocumentsSchema.new(request.params)
      realizer = DocumentRealizer.new(intent: :index, parameters: schema, headers: request.headers)
      documents = realizer.object
      render json: JSONAPI::Serializer.serialize(realizer.object, is_collection: true, meta: { page_offset: page_offset, page_limit: page_limit }), status: :ok
    end
  end

  # DELETE /:identifier/documents/:id
  def destroy
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Document, :destroy?
      schema = ShowDocumentSchema.new(request.params)
      realizer = DocumentRealizer.new(intent: :show, parameters: schema, headers: request.headers)
      realizer.object.discard!
    end
  end

  # PUT /:identifier/documents/:id/restore
  def restore
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Document, :update?
      schema = ShowDocumentSchema.new(request.params)
      realizer = DocumentRealizer.new(intent: :show, parameters: schema, headers: request.headers)
      realizer.object.undiscard!
      render json: JSONAPI::Serializer.serialize(realizer.object), status: :ok
    end
  end

  # GET /:identifier/documents/:id/folder
  def folder
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Document, :show?
      authorize Folder, :show?
      schema = ShowDocumentSchema.new(request.params)
      realizer = DocumentRealizer.new(intent: :show, parameters: schema, headers: request.headers)
      render json: JSONAPI::Serializer.serialize(realizer.object.folder)
    end
  end

  # GET /:identifier/documents/:id/download
  def download
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Document, :show?
      schema = ShowDocumentSchema.new(request.params)
      realizer = DocumentRealizer.new(intent: :show, parameters: schema, headers: request.headers)
      serve_content(realizer.object)
    end
  end

  # GET /:identifier/documents/:id/versions/:version/download
  def download_version
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Document, :show?
      schema = ShowDocumentSchema.new(request.params)
      realizer = DocumentRealizer.new(intent: :show, parameters: schema, headers: request.headers)
      version = realizer.object.versions.find(schema.version)
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
end
