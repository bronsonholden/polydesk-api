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

  before_save do
    if name_changed?
      update_path
    end
  end

  # TODO: Broken
  # after_update do
  #   if saved_changes.include?('name')
  #     update_child_paths
  #   end
  # end
  #
  # def update_child_paths
  #   children.each { |child|
  #     child.update_path!
  #   }
  # end

  def update_path!
    update_path
    save!
  end

  def update_path
    if parent_id == 0
      self.path = '/' + name
    else
      parent_path = parent.path
      self.path = [parent_path, name].join('/')
    end
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
