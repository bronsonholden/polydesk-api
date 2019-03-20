class FormSerializer
  include FastJsonapi::ObjectSerializer
  attributes :name, :schema

  attribute :layout do |form|
    form.layout || {}
  end
end
