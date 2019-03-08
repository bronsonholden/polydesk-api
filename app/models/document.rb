class Document < ApplicationRecord
  include Rails.application.routes.url_helpers

  mount_uploader :content, DocumentUploader
  validates :content, presence: true
  has_one :folder_document, dependent: :destroy
  has_one :folder, through: :folder_document

  def related_folder_url
    document_folder_url(id: self.id, identifier: Apartment::Tenant.current)
  end

  before_save :save_content_attributes

  def save_content_attributes
    self.content_type = content.content_type if content.content_type
    self.file_size = content.size
  end
end
