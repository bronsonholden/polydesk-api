class FormSerializer < TenantSerializer
  attributes :name, :layout, :created_at, :updated_at, :discarded_at
  attribute :unique_fields do
    if object.unique_fields.nil?
      []
    else
      object.unique_fields
    end
  end
  attribute :schema do
    JSON.parse(object.schema)
  end

  has_many :form_submissions
end
