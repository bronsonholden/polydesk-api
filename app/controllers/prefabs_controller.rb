class PrefabsController < ApplicationController
  before_action :authenticate_user!

  def create
    schema = CreatePrefabSchema.new(request.params)
    payload = schema.render
    realizer = PrefabRealizer.new(intent: :create, parameters: payload, headers: request.headers)
    prefab = realizer.object
    authorize prefab
    prefab.save!
    render json: JSONAPI::Serializer.serialize(prefab), status: :created
  end

  def show
    schema = ShowPrefabSchema.new(request.params)
    payload = schema.render
    scope = Prefab.partition_key_eq(payload["namespace"])
    realizer = PrefabRealizer.new(intent: :show, parameters: payload, headers: request.headers, scope: scope)
    authorize realizer.object
    render json: JSONAPI::Serializer.serialize(realizer.object), status: :ok
  end

  def index
    schema = IndexPrefabsSchema.new(request.params)
    payload = schema.render
    scope = PrefabQuery.new(payload).apply(Prefab.partition_key_eq(payload['namespace']))
    realizer = PrefabRealizer.new(intent: :index, parameters: payload.except('filter', 'sort'), headers: request.headers, scope: scope)
    authorize realizer.object
    pagination_props = PaginationProperties.new(page_offset, page_limit, realizer.total_count)
    render json: JSONAPI::Serializer.serialize(realizer.object, is_collection: true, meta: pagination_props.generate), status: :ok
  end
end
