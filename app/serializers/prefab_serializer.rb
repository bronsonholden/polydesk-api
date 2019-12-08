class PrefabSerializer < TenantSerializer
  attributes :namespace, :tag, :schema, :view, :data
  has_one :blueprint, class_name: 'Blueprint'
end
