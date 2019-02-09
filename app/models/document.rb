class Document < ApplicationRecord
  mount_uploader :content, DocumentUploader
  validates :content, presence: true
  has_one :folder_document, dependent: :destroy
  has_one :folder, through: :folder_document
end
