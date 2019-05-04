class Document < ApplicationRecord
  has_paper_trail ignore: [:discarded_at]

  include Rails.application.routes.url_helpers
  include Polydesk::VerifyDocument
  include Polydesk::Uploader
  include Discard::Model

  mount_uploader :content, DocumentUploader
  upload_in_background :content
  validates :content, presence: true
  validates :name, presence: true, format: {
    # Allow alphanumerals, spaces, and _ . - ( ) [ ]
    # The first character may not be a space, and the last must not be a space or period.
    with: /\A[A-Za-z0-9\-\(\)\[\]'_\.][A-Za-z0-9 \-\(\)\[\]'_\.]*[A-Za-z0-9\-\(\)\[\]'_]\z/,
    message: 'may only contain alphanumerals, spaces, or the following: _ . - ( ) [ ] and may not start with a space or end with either a space or .'
  }
  validates :name, uniqueness: { scope: [:folder_id, :unique_enforcer] },
                   unless: Proc.new { |doc| doc.unique_enforcer.nil? }
  belongs_to :folder, optional: true

  def related_folder_url
    document_folder_url(id: self.id, identifier: Apartment::Tenant.current)
  end

  before_validation :default_folder, :set_document_name
  before_save :save_content_attributes, :within_storage_limit

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
