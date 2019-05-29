class FolderSerializer < ApplicationSerializer
  attributes :name, :created_at, :updated_at, :discarded_at
  has_one :parent
  has_many :children
  has_many :documents
end
