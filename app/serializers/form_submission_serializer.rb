class FormSubmissionSerializer < TenantSerializer
  attribute :state do
    object.current_state
  end

  attribute :schema_snapshot do
    JSON.parse(object.schema_snapshot)
  end

  attributes :data, :created_at, :updated_at
  has_one :form, class_name: 'Form'
  has_one :submitter, class_name: 'User'
end
