class PermissionSerializer
  include FastJsonapi::ObjectSerializer
  attributes :created_at, :updated_at
end
