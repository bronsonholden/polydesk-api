class FormSubmissionTransition < ApplicationRecord
  belongs_to :form_submission, inverse_of: :form_submission_transitions
  after_destroy :update_most_recent, if: :most_recent?
  validates :to_state, inclusion: { in: FormSubmissionStateMachine.states }

  def self.updated_timestamp_column
    nil
  end

  private

  def update_most_recent
    last_transition = form_submission.form_submission_transitions.order(:sort_key).last
    return unless last_transition.present?
    last_transition.update_column(:most_recent, true)
  end
end
