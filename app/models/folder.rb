class Folder < ApplicationRecord
  has_paper_trail ignore: [:discarded_at]

  include Discard::Model
  include Polydesk::Model::Validations::Folder

  belongs_to :folder, optional: true
  has_many :folders, dependent: :destroy
  has_many :documents, dependent: :destroy

  before_validation do
    self.folder_id ||= 0
  end
end
