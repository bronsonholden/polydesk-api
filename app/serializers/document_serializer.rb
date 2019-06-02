class DocumentSerializer < TenantSerializer
  attributes :content_type, :file_size, :created_at, :updated_at, :name, :discarded_at
  attribute :folder_id
  has_one :folder
end
