class FolderSerializer < TenantSerializer
  attributes :name, :created_at, :updated_at, :discarded_at
  has_one :folder
  has_many :folders
  has_many :documents
end
