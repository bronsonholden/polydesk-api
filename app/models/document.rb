require 'elasticsearch/model'

class Document < ApplicationRecord
  include Rails.application.routes.url_helpers
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  index_name { "documents-#{Apartment::Tenant.current || 'public'}-#{Rails.env}" }

  settings do
    mappings dynamic: false do
      indexes :name, type: :text, analyzer: :english, index_options: :offsets
    end
  end

  mount_uploader :content, DocumentUploader
  validates :content, presence: true
  has_one :folder_document, dependent: :destroy
  has_one :folder, through: :folder_document

  def related_folder_url
    document_folder_url(id: self.id, identifier: Apartment::Tenant.current)
  end

  before_save :save_content_attributes
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
