class PrefabRealizer
  include JSONAPI::Realizer::Resource
  type :prefabs, class_name: 'Prefab', adapter: :active_record
  has_one :blueprint, class_name: 'BlueprintRealizer'
  has :namespace
  has :tag
  has :schema
  has :view
  has :data
end
