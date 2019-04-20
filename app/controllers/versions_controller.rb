class VersionsController < ApplicationController
  before_action :authenticate_user!

  # GET /:identifier/:model/:id/versions
  def index
    Apartment::Tenant.switch(params['identifier']) do
      set_data
      render json: VersionSerializer.new(@object.versions).serialized_json, status: :ok
    end
  end

  # GET /:identifier/:model/:id/versions/:version
  def show
    Apartment::Tenant.switch(params['identifier']) do
      set_data
      set_version
      render json: VersionSerializer.new(@version).serialized_json, status: :ok
    end
  end

  # PUT /:identifier/:model/:id/versions/:version
  def reify
    Apartment::Tenant.switch(params['identifier']) do
      set_data
      set_version
      @reified = @version.reify
      @reified.save
      render json: @serializer.new(@reified).serialized_json, status: :ok
    end
  end

  private
    def set_version
      @version = @object.versions.find(params[:version])
    end

    def set_data
      @model_name = params[:model].singularize

      # Eager load while outside of production, so we can list all models
      Rails.application.eager_load! if Rails.env != 'production'

      # Since model name is parameterized for versions, we need to throw
      # a routing error if it doesn't look like we were given a valid
      # model name.
      if !ApplicationRecord.descendants.map(&:name).include?(@model_name.capitalize)
        msg = "No route matches [#{request.method}] \"#{request.path}\""
        raise ActionController::RoutingError.new(msg)
      end

      @serializer = (@model_name + 'Serializer').classify.constantize
      @model = @model_name.classify.constantize
      @object = @model.find(params[:id])

      # If the model is valid, but not something that has versions, raise
      # a NotVersionableException. The paper_trail instance method is
      # included by any class that defines has_paper_trail
      if !@model.instance_methods(true).include?(:paper_trail)
        raise Polydesk::ApiExceptions::NotVersionableException.new(@object)
      end
    end
end
