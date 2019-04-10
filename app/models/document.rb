class Document < ApplicationRecord
  has_paper_trail

  include Rails.application.routes.url_helpers
  include Polydesk::VerifyDocument

  mount_uploader :content, DocumentUploader
  validates :content, presence: true
  has_one :folder_document, dependent: :destroy
  has_one :folder, through: :folder_document

  def related_folder_url
    document_folder_url(id: self.id, identifier: Apartment::Tenant.current)
  end

  before_save :save_content_attributes, :within_storage_limit
  before_create :set_document_name

  def set_document_name
    self.name = File.basename(self.content.path) if name.blank? || name.nil?
  end

  def save_content_attributes
    self.content_type = content.content_type if content.content_type
    self.file_size = content.size
  end

  def url
    document_url(id: self.id, identifier: Apartment::Tenant.current)
  end
end
