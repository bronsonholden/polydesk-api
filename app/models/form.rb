class Form < ApplicationRecord
  include Discard::Model

  has_many :form_submissions

  validates :name, presence: true, uniqueness: true
  validate :check_schema
  validate :check_layout

  private

  def check_schema
    errors.add('schema', 'must be provided') if schema.nil?
    validate_schema_keys(JSON.parse(schema))
  end

  def validate_schema_keys(s)
    return if s['type'] != 'object'
    props = s.fetch('properties', nil)
    return if props.nil?
    props.each { |prop, prop_schema|
      m = prop.match(/\A[-_a-zA-Z0-9]+\z/)
      if m.nil?
        raise Polydesk::Errors::InvalidFormSchemaKey.new(prop)
      end
      validate_schema_keys(prop_schema)
    }
  end

  def check_layout
    errors.add('layout', 'must be provided') if layout.nil?
  end
end
