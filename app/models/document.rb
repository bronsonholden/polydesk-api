class Document < ApplicationRecord
  # Ignore Shrine data column so versions aren't triggered when files move
  # from cache.
  has_paper_trail ignore: [:discarded_at, :content_data]

  include Rails.application.routes.url_helpers
  include Polydesk::VerifyDocument
  include Discard::Model

  include DocumentContentUploader::Attachment.new(:content)
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

  attr_accessor :skip_background_upload

  after_create do
    if self.skip_background_upload
      self.content_attacher.promote
    end
  end

  # Destroy this record's associated versions
  before_destroy do
    self.versions.destroy_all
  end

  def default_folder
    self.folder_id ||= 0
  end

  def set_document_name
    if self.content
      self.name = self.content.metadata['filename'] if self.name.blank? || self.name.nil?
    end
  end

  def save_content_attributes
    if content
      self.content_type = content.metadata['mime_type']
      self.file_size = content.metadata['size']
    end
  end

  def url
    document_url(id: self.id, identifier: Apartment::Tenant.current)
  end
end
