class DocumentSerializer < ApplicationSerializer
  attributes :content_type, :file_size, :created_at, :updated_at, :name, :discarded_at
  has_one :folder

  def meta
    { latest_version: object.versions.last.id } if object.versions.any?
  end
end
