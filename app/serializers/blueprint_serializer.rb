class BlueprintSerializer < TenantSerializer
  attributes :name, :namespace, :schema, :view, :construction_view, :created_at, :updated_at
end
