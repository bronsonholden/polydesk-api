class Folder < ApplicationRecord
  include Rails.application.routes.url_helpers

  has_paper_trail

  alias_attribute :parent_folder, :parent_id
  belongs_to :parent, class_name: 'Folder', optional: true
  before_validation :default_parent
  has_many :children, class_name: 'Folder', foreign_key: 'parent_id', dependent: :destroy
  has_many :folder_documents, dependent: :destroy
  has_many :documents, through: :folder_documents
  validates :name, presence: true, format: {
    # Allow alphanumerals, spaces, and _ . - ( ) [ ]
    # Spaces and . may not be the first or last character
    with: /\A([A-Za-z0-9\-\(\)\[\]'_][A-Za-z0-9 \-\(\)\[\]'_\.]*[A-Za-z0-9\-\(\)\[\]'_]|[A-Za-z0-9\-\(\)\[\]\|'_]{1,2})\z/,
    message: 'may only contain alphanumerals, spaces, or the following: _ . - ( ) [ ] and may not start or end with a space or .'
  }, uniqueness: { scope: :parent_id }

  validates_each :parent_id do |record, attr, value|
    record.errors.add('parent_folder', 'does not exist') unless value.zero? or Folder.find_by_id(value)
  end

  def default_parent
    self.parent_id ||= 0
  end

  def url
    folder_url(id: self.id, identifier: Apartment::Tenant.current)
  end

  def related_documents_url
    folder_documents_url(id: self.id, identifier: Apartment::Tenant.current)
  end

  def related_folders_url
    folder_folders_url(id: self.id, identifier: Apartment::Tenant.current)
  end
end
