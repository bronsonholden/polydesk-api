class PrefabSerializer < TenantSerializer
  attributes :namespace, :tag, :schema, :view, :data, :created_at, :updated_at
  has_one :blueprint, class_name: 'Blueprint'
end
