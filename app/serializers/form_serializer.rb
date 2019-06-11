class FormSerializer < TenantSerializer
  attributes :name, :schema, :layout, :created_at, :updated_at, :discarded_at
end
