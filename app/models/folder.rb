class Folder < ApplicationRecord
  has_paper_trail ignore: [:discarded_at]

  include Discard::Model
  include Polydesk::Model::Validations::Folder

  alias_attribute :parent_folder, :parent_id

  belongs_to :parent, class_name: 'Folder', optional: true
  has_many :children, class_name: 'Folder', foreign_key: 'parent_id', dependent: :destroy
  has_many :documents, dependent: :destroy

  before_validation do
    self.parent_id ||= 0
  end
end
