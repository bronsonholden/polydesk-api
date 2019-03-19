class FormSerializer
  include FastJsonapi::ObjectSerializer
  attributes :name

  attribute :schema do |form|
    form.schema || ''
  end
end
