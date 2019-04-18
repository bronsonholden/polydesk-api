class Document < ApplicationRecord
  has_paper_trail ignore: [:discarded_at]

  include Rails.application.routes.url_helpers
  include Polydesk::VerifyDocument
  include Discard::Model

  mount_uploader :content, DocumentUploader
  validates :content, presence: true
  belongs_to :folder, optional: true

  def related_folder_url
    document_folder_url(id: self.id, identifier: Apartment::Tenant.current)
  end

  before_validation :default_folder
  before_save :save_content_attributes, :within_storage_limit
  before_create :set_document_name

  # Destroy this record's associated versions
  before_destroy do
    self.versions.destroy_all
  end

  def default_folder
    self.folder_id ||= 0
  end

  def set_document_name
    self.name = File.basename(self.content.path) if name.blank? || name.nil?
  end

  def save_content_attributes
    if content
      self.content_type = content.content_type
      self.file_size = content.size
    end
  end

  def url
    document_url(id: self.id, identifier: Apartment::Tenant.current)
  end
end
