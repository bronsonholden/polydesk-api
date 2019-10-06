class FormSubmissionSerializer < TenantSerializer
  attribute :schema_snapshot do
    JSON.parse(object.schema_snapshot)
  end

  attributes :data, :created_at, :updated_at
  has_one :form, class_name: 'Form'
  has_one :submitter, class_name: 'User'

  def meta
    virtual_columns = object.attributes.keys - object.class.column_names
    if virtual_columns.any?
      meta = {}
      virtual_columns.map(&:to_sym).each { |col|
        meta[col] = object.send(col)
      }
      meta
    else
      nil
    end
  end
end
