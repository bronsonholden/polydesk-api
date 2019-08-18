require 'json'

class DocumentsController < ApplicationController
  before_action :authenticate_user!

  # POST /:identifier/documents
  def create
    schema = CreateDocumentSchema.new(request.params)
    payload = sanitize_payload(schema.render, Document)
    realizer = DocumentRealizer.new(intent: :create, parameters: payload, headers: request.headers)
    authorize realizer.object
    realizer.object.save!
    render json: JSONAPI::Serializer.serialize(realizer.object), status: :created
  end

  # Non-JSON:API create
  def upload_new
    document = Document.create(params.permit(:content, :name))
    authorize document
    document.save!
    render json: JSONAPI::Serializer.serialize(document), status: :created
  end

  # Non-JSON:API update
  def upload_version
    document = Document.find(params.permit(:id).fetch(:id))
    document.update(params.permit(:content, :name))
    authorize document, :update?
    document.save!
    render json: JSONAPI::Serializer.serialize(document), status: :ok
  end

  # PATCH/PUT /:identifier/documents/:id
  def update
    schema = UpdateDocumentSchema.new(request.params)
    payload = sanitize_payload(schema.render, Document)
    realizer = DocumentRealizer.new(intent: :update, parameters: payload, headers: request.headers)
    authorize realizer.object
    realizer.object.save!
    render json: JSONAPI::Serializer.serialize(realizer.object), status: :ok
  end

  # POST /:identifier/documents/:id
  def show
    schema = ShowDocumentSchema.new(request.params)
    payload = schema.render
    realizer = DocumentRealizer.new(intent: :show, parameters: payload, headers: request.headers)
    authorize realizer.object
    render json: JSONAPI::Serializer.serialize(realizer.object, include: (payload['include'].split(',') if payload.key?('include'))), status: :ok
  end

  # GET /:identifier/documents
  def index
    schema = IndexDocumentsSchema.new(request.params)
    payload = schema.render
    realizer = DocumentRealizer.new(intent: :index, parameters: payload, headers: request.headers)
    authorize realizer.object
    documents = realizer.object
    pagination_props = PaginationProperties.new(page_offset, page_limit, Document.all.count)
    render json: JSONAPI::Serializer.serialize(realizer.object, is_collection: true, include: (payload['include'].split(',') if payload.key?('include')), meta: pagination_props.generate), status: :ok
  end

  # DELETE /:identifier/documents/:id
  def destroy
    schema = ShowDocumentSchema.new(request.params)
    payload = schema.render
    realizer = DocumentRealizer.new(intent: :show, parameters: payload, headers: request.headers)
    authorize realizer.object
    realizer.object.discard!
  end

  # PUT /:identifier/documents/:id/restore
  def restore
    schema = ShowDocumentSchema.new(request.params)
    payload = schema.render
    realizer = DocumentRealizer.new(intent: :show, parameters: payload, headers: request.headers)
    authorize realizer.object, :update?
    realizer.object.undiscard!
    render json: JSONAPI::Serializer.serialize(realizer.object), status: :ok
  end

  # GET /:identifier/documents/:id/folder
  def folder
    schema = ShowDocumentSchema.new(request.params)
    payload = schema.render
    realizer = DocumentRealizer.new(intent: :show, parameters: payload, headers: request.headers)
    authorize realizer.object, :show?
    authorize realizer.object.folder, :show?, policy_class: FolderPolicy
    render json: JSONAPI::Serializer.serialize(realizer.object.folder)
  end

  # GET /:identifier/documents/:id/download
  def download
    schema = ShowDocumentSchema.new(request.params)
    payload = schema.render
    realizer = DocumentRealizer.new(intent: :show, parameters: payload, headers: request.headers)
    authorize realizer.object, :show?
    serve_content(realizer.object)
  end

  # GET /:identifier/documents/:id/versions/:version/download
  def download_version
    schema = ShowDocumentSchema.new(request.params)
    payload = schema.render
    realizer = DocumentRealizer.new(intent: :show, parameters: payload, headers: request.headers)
    authorize realizer.object, :show?
    version = realizer.object.versions.find(payload["version"])
    serve_content(version.reify)
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
