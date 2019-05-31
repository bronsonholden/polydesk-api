class VersionsController < ApplicationController
  before_action :authenticate_user!

  # GET /:identifier/:model/:id/versions
  def index
    Apartment::Tenant.switch(params['identifier']) do
      set_data
      pagination_props = PaginationProperties.new(page_offset, page_limit, @object.versions.size)
      render json: JSONAPI::Serializer.serialize(@object.versions, is_collection: true, meta: pagination_props), status: :ok
    end
  end

  # GET /:identifier/:model/:id/versions/:version
  def show
    Apartment::Tenant.switch(params['identifier']) do
      set_data
      set_version
      render json: JSONAPI::Serializer.serialize(@version), status: :ok
    end
  end

  # TODO: Fix - Duplicate action
  # PUT /:identifier/:model/:id/versions/:version
  def restore
    Apartment::Tenant.switch(params['identifier']) do
      set_data
      set_version
      @reified = @version.reify
      @reified.save!
      render json: JSONAPI::Serializer.serialize(@reified), status: :ok
    end
  end

  private
    def set_version
      @version = @object.versions.find(params[:version])
    end

    def set_data
      versionable = %w(document folder)
      @model_name = params[:model].singularize

      if !versionable.include?(@model_name)
        raise Polydesk::ApiExceptions::NotVersionable.new(@object)
      end

      @model = @model_name.classify.constantize
      @object = @model.find(params[:id])
    end
end
