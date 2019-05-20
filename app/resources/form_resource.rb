class FormSerializer
  include FastJsonapi::ObjectSerializer
  attributes :name, :schema, :layout, :created_at, :updated_at
  link :self, -> (form) {
    form.url
  }
end
