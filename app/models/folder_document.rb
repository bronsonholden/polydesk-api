class FolderDocument < ApplicationRecord
  validates :folder_id, presence: true
  validates :document_id, presence: true, uniqueness: true
  belongs_to :folder
  belongs_to :document, dependent: :destroy
end
