class BlueprintRealizer
  include JSONAPI::Realizer::Resource
  type :blueprints, class_name: 'Blueprint', adapter: :active_record
  has :name
  has :namespace
  has :schema
  has :view
  has :list_view
  has :construction_view
end
