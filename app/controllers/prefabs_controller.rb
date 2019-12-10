class PrefabsController < ApplicationController
  before_action :authenticate_user!

  def create
    schema = CreatePrefabSchema.new(request.params)
    payload = schema.render
    realizer = PrefabRealizer.new(intent: :create, parameters: payload, headers: request.headers)
    authorize realizer.object
    # If constructing (blueprint ref provided), assign everything except data
    if !realizer.object.blueprint.nil?
      blueprint = realizer.object.blueprint
      realizer.object.schema = blueprint.schema
      realizer.object.view = blueprint.view
      realizer.object.namespace = blueprint.namespace
    end
    realizer.object.save!
    render json: JSONAPI::Serializer.serialize(realizer.object), status: :created
  end

  def show
    schema = ShowPrefabSchema.new(request.params)
    payload = schema.render
    realizer = PrefabRealizer.new(intent: :show, parameters: payload, headers: request.headers)
    authorize realizer.object
    render json: JSONAPI::Serializer.serialize(realizer.object), status: :ok
  end

  def index
    schema = IndexPrefabsSchema.new(request.params)
    payload = schema.render
    realizer = PrefabRealizer.new(intent: :index, parameters: payload, headers: request.headers)
    authorize realizer.object
    pagination_props = PaginationProperties.new(page_offset, page_limit, realizer.total_count)
    render json: JSONAPI::Serializer.serialize(realizer.object, is_collection: true, meta: pagination_props.generate), status: :ok
  end
end
