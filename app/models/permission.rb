class Permission < ApplicationRecord
  enum code: [
    :document_create,
    :document_show,
    :document_index,
    :document_update,
    :document_destroy,
    :folder_create,
    :folder_show,
    :folder_index,
    :folder_update,
    :folder_destroy,
    :folder_folders,
    :folder_documents,
    :folder_add_folder,
    :folder_add_document
  ]

  validates :code, presence: true, uniqueness: { scope: :account_user_id }
  validates :account_user_id, presence: true
  # Set foreign key to excluded AccountUser model
  belongs_to :account_user, class_name: 'AccountUser', foreign_key: 'account_user_id'
end
