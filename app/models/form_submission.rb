class FormSubmission < ApplicationRecord
  attr_readonly :flat_data

  validates :data, presence: true
  validates :flat_data, presence: true
  belongs_to :form
  belongs_to :submitter, class_name: 'User', foreign_key: 'submitter_id'

  before_validation :form_snapshot, on: :create
  before_validation :flatten_data

  protected

  def flatten_data
    self.flat_data = Smush.smush(data)
  end

  def form_snapshot
    self.schema_snapshot = form.schema.deep_dup
    self.layout_snapshot = form.layout.deep_dup
  end
end
