class FormSubmissionRealizer
  include JSONAPI::Realizer::Resource
  type :form_submissions, class_name: 'FormSubmission', adapter: :active_record_no_filtering
  has :data
  has :state
  has_one :form, class_name: 'FormRealizer'
  has_one :submitter, class_name: 'UserRealizer'
end
