class DocumentSerializer < TenantSerializer
  attributes :content_type, :file_size, :created_at, :updated_at, :name, :discarded_at
  attribute :folder_id

  attribute :owner do
    nil
  end

  attribute :version do
    object.versions.size + 1
  end

  has_one :folder
end
