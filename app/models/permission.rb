class Permission < ApplicationRecord
  enum code: [
    :document_create,
    :document_show,
    :document_index
  ]

  validates :code, presence: true
  validates :account_user_id, presence: true
  # Set foreign key to excluded AccountUser model
  belongs_to :account_user, class_name: 'AccountUser', foreign_key: 'account_user_id'
end
