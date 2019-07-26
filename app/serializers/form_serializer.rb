class FormSerializer < TenantSerializer
  attributes :name, :layout, :created_at, :updated_at, :discarded_at
  attribute :schema do
    JSON.parse(object.schema)
  end

  has_many :form_submissions
end
