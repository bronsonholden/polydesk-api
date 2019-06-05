class FormSubmissionSerializer < ApplicationSerializer
  attributes :data, :created_at, :updated_at
  has_one :form
  has_one :submitter, class_name: 'User'
end
