class Blueprint < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :namespace, presence: true, uniqueness: true, format: {
    with: /\A[a-z\-_0-9]+\z/,
    message: 'many only container lowercase letters, numbers, -, and _.'
  }
  validates :schema, presence: true
  validates :view, presence: true
  validate :check_schema

  before_create :create_prefabs_partition

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
          if prop.match(/\A[a-zA-Z_]([a-zA-Z_0-9])*\z/).nil?
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

  # Create a Prefabs partition table for the Blueprint's namespace
  def create_prefabs_partition
    name = Prefab.partition_name(namespace)
    Prefab.create_partition values: namespace, primary_key: :id, name: name
  end
end
