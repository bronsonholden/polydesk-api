class BlueprintRealizer
  include JSONAPI::Realizer::Resource
  type :blueprints, class_name: 'Blueprint', adapter: :active_record
  has :name
  has :namespace
  has :schema
end
