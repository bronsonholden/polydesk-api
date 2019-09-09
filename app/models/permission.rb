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
    :folder_add_document,
    :form_create,
    :form_show,
    :form_index,
    :form_update,
    :form_destroy,
    :report_create,
    :report_show,
    :report_index,
    :report_update,
    :report_destroy,
    :account_update,
    :form_submission_create,
    :form_submission_show,
    :form_submission_index,
    :form_submission_update,
    :form_submission_destroy
  ]

  validates :code, presence: true, uniqueness: { scope: :account_user_id }
  validates :account_user_id, presence: true
  # Set foreign key to excluded AccountUser model
  belongs_to :account_user, class_name: 'AccountUser', foreign_key: 'account_user_id'
end
