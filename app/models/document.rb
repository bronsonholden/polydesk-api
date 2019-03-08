class Document < ApplicationRecord
  include Rails.application.routes.url_helpers

  mount_uploader :content, DocumentUploader
  validates :content, presence: true
  has_one :folder_document, dependent: :destroy
  has_one :folder, through: :folder_document

  def related_folder_url
    document_folder_url(id: self.id, identifier: Apartment::Tenant.current)
  end
end
