class FormSerializer
  include FastJsonapi::ObjectSerializer
  attributes :name, :schema, :layout, :created_at, :updated_at
end
