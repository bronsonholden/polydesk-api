class Blueprint < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :namespace, presence: true, uniqueness: true
  validates :schema, presence: true
  validates :view, presence: true
  validate :check_schema

  def check_schema
    validate_schema_keys(schema)
  end

  def validate_schema_keys(schema)
    return if schema['type'] != 'object'
    props = schema.fetch('properties', nil)
    return if props.nil?
    props.each { |prop, prop_schema|
      m = prop.match(/\A[-_a-zA-Z0-9]+\z/)
      if m.nil?
        raise Polydesk::Errors::InvalidBlueprintSchema.new("#{prop} contains invalid characters; may only contain alphanumerics, -, or _")
      end
      validate_schema_keys(prop_schema)
    }
  end
end
