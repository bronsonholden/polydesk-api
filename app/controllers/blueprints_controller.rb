class BlueprintsController < ApplicationController
  before_action :authenticate_user!

  def create
    schema = CreateBlueprintSchema.new(request.params)
    payload = schema.render
    realizer = BlueprintRealizer.new(intent: :create, parameters: payload, headers: request.headers)
    authorize realizer.object
    realizer.object.save!
    render json: JSONAPI::Serializer.serialize(realizer.object), status: :created
  end

  def index
    schema = IndexBlueprintsSchema.new(request.params)
    payload = schema.render
    realizer = BlueprintRealizer.new(intent: :index, parameters: payload, headers: request.headers)
    authorize realizer.object
    render json: JSONAPI::Serializer.serialize(realizer.object, is_collection: true), status: :ok
  end

  def show
    schema = ShowBlueprintSchema.new(request.params)
    payload = schema.render
    realizer = BlueprintRealizer.new(intent: :show, parameters: payload, headers: request.headers)
    authorize realizer.object
    render json: JSONAPI::Serializer.serialize(realizer.object), status: :ok
  end
end
