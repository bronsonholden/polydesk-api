class FormSubmissionSerializer < ApplicationSerializer
  attribute :state do
    object.current_state
  end
  attributes :data, :created_at, :updated_at
  has_one :form
  has_one :submitter, class_name: 'User'
end
