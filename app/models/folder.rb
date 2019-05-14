class Folder < ApplicationRecord
  has_paper_trail ignore: [:discarded_at]

  include Rails.application.routes.url_helpers
  include Discard::Model
  include Polydesk::Model::Validations::Folder

  alias_attribute :parent_folder, :parent_id

  belongs_to :parent, class_name: 'Folder', optional: true
  has_many :children, class_name: 'Folder', foreign_key: 'parent_id', dependent: :destroy
  has_many :documents, dependent: :destroy

  before_validation do
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
