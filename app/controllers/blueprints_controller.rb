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
end
