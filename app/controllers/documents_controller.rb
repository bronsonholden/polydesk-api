require 'json'

class DocumentsController < ApplicationController
  before_action :authenticate_user!

  # POST /:identifier/documents
  def create
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Document, :create?
      schema = CreateDocumentSchema.new(request.params)
      payload = sanitize_payload(schema.to_hash, Document)
      realizer = DocumentRealizer.new(intent: :create, parameters: payload, headers: request.headers)
      realizer.object.save!
      render json: JSONAPI::Serializer.serialize(realizer.object), status: :created
    end
  end

  # Non-JSON:API create
  def upload_new
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Document, :create?
      document = Document.create!(params.permit(:content, :name))
      render json: JSONAPI::Serializer.serialize(document), status: :created
    end
  end

  # Non-JSON:API update
  def upload_version
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Document, :create?
      document = Document.find(params.permit(:id).fetch(:id))
      document.update!(params.permit(:content, :name))
      render json: JSONAPI::Serializer.serialize(document), status: :ok
    end
  end

  # PATCH/PUT /:identifier/documents/:id
  def update
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Document, :update?
      schema = UpdateDocumentSchema.new(request.params)
      payload = sanitize_payload(schema.to_hash, Document)
      realizer = DocumentRealizer.new(intent: :update, parameters: payload, headers: request.headers)
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
      render json: JSONAPI::Serializer.serialize(realizer.object, include: (schema.include.split(',') if schema.key?('include'))), status: :ok
    end
  end

  # GET /:identifier/documents
  def index
    Apartment::Tenant.switch(params[:identifier]) do
      authorize Document, :index?
      schema = IndexDocumentsSchema.new(request.params)
      realizer = DocumentRealizer.new(intent: :index, parameters: schema, headers: request.headers)
      documents = realizer.object
      render json: JSONAPI::Serializer.serialize(realizer.object, is_collection: true, include: (schema.include.split(',') if schema.key?('include'))), status: :ok
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
