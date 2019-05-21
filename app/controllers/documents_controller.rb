require 'json'

class DocumentsController < ApplicationController
  # User must be authenticated before they can interact with documents
  before_action :authenticate_user!

  # PUT /:identifier/documents/:id/restore
  def restore
    authorize Document, :update?
    @document = Document.find(params[:id])
    @document.undiscard!
    render json: JSONAPI::ResourceSerializer.new(DocumentResource).serialize_to_hash(DocumentResource.new(@document.reload, nil)), status: :ok
  end

  # GET /:identifier/documents/:id/download
  def download
    authorize Document, :show?
    @document = Document.find(params[:id])
    serve_content(@document)
  end

  # GET /:identifier/documents/:id/versions/:version/download
  def download_version
    authorize Document, :show?
    @document = Document.find(params[:id])
    @version = @document.versions.find(params[:version])
    serve_content(@version.reify)
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
