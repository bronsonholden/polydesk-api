class FormSerializer
  include FastJsonapi::ObjectSerializer
  attributes :name, :schema, :layout
end
