class Option < ApplicationRecord
  enum name: [
    :document_storage_limit
  ]

  validates :name, presence: true
  validates :value, presence: true
end
