class Document < ApplicationRecord
  mount_uploader :content, DocumentUploader
  validates :content, presence: true
end
