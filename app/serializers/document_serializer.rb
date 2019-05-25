class DocumentSerializer < ApplicationSerializer
  attributes :content_type, :file_size, :created_at, :updated_at, :name, :discarded_at
  has_one :folder
end
