class FormSubmission < ApplicationRecord
  include Statesman::Adapters::ActiveRecordQueries

  has_many :form_submission_transitions, autosave: false

  attr_readonly :flat_data
  attr_readonly :schema_snapshot
  attr_readonly :layout_snapshot
  attr_accessor :state

  belongs_to :form
  belongs_to :submitter, class_name: 'User', foreign_key: 'submitter_id'

  before_validation :form_snapshot, on: :create
  before_validation :flatten_data, :validate_schema

  def state_machine
    @state_machine ||= FormSubmissionStateMachine.new(self, transition_class: FormSubmissionTransition)
  end

  def self.transition_class
    FormSubmissionTransition
  end

  def self.initial_state
    :draft
  end

  private_class_method :initial_state

  delegate :can_transition_to?, :transition_to!, :transition_to, :current_state, to: :state_machine

  protected

  def validate_schema
    valid = JSON::Validator.validate(self.schema_snapshot, self.data)
    raise Polydesk::ApiExceptions::FormSchemaViolated.new(self) if !valid
  end

  def flatten_data
    self.data ||= {}
    self.flat_data = Smush.smush(data)
  end

  def form_snapshot
    self.schema_snapshot = form.schema.deep_dup
    self.layout_snapshot = form.layout.deep_dup
  end
end
