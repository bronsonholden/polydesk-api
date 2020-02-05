class Blueprint < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :namespace, presence: true, uniqueness: true
  validates :schema, presence: true
  validates :view, presence: true
  validate :check_schema

  def check_schema
    validate_subschema(schema)
  end

  def validate_subschema(subschema, path = '$')
    type = subschema['type']
    if type == 'object'
      props = subschema.fetch('properties', nil)
      if !props.nil?
        props.each { |prop, prop_schema|
          subpath = [path, prop].join('.')
          if prop.match(/\A[-_a-zA-Z0-9]+\z/).nil?
            raise Polydesk::Errors::InvalidBlueprintSchema.new("'#{subpath}' contains invalid characters; may only contain alphanumerics, -, or _")
          end
          validate_subschema(prop_schema, subpath)
        }
      end
    end
    defer = subschema['defer']
    if !defer.nil?
      # validate_defer_subschema(prop_schema)
    end
    prefab = subschema['prefab']
    if !prefab.nil?
      # validate_prefab_schema
    end
  end
end
