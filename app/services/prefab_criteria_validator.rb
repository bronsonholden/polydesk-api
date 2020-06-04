# Validates "prefab" property in blueprint schemas. This subschema defines
# criteria used for selecting related elements.
class PrefabCriteriaValidator
  def self.validate(schema)
    JSON::Validator.validate(self.schema, schema)
  end

  def self.validate!(schema)
    JSON::Validator.validate!(self.schema, schema)
  end

  def self.schema
    {
      condition: {
        type: 'array',
        items: {
          type: 'string'
        }
      }
    }
  end
end
