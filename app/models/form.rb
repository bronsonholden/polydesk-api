class Form < ApplicationRecord
  include Discard::Model

  has_many :form_submissions

  validates :name, presence: true, uniqueness: true
  validate :check_schema
  validate :check_layout

  private

  def check_schema
    errors.add('schema', 'must be provided') if schema.nil?
  end

  def check_layout
    errors.add('layout', 'must be provided') if layout.nil?
  end
end
