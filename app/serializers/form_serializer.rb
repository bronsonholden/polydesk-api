class FormSerializer
  include FastJsonapi::ObjectSerializer
  attributes :name, :schema
end
