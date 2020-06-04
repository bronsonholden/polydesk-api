# This validates a prefab criteria subschema (specified as "prefab" in
# the blueprint schema).
class PrefabMetaschema
  def self.validate(schema)
    if schema.key?('prefab')
      t = JSON::Validator.validate(self.schema, schema['prefab'])
    elsif schema.key?(:prefab)
      JSON::Validator.validate(self.schema, schema[:prefab])
    else
      schema.each { |key, val|
        if val.is_a?(Hash) && self.validate(val) == false
          return false
        end
      }
      true
    end
  end

  def self.schema
    {
      type: 'object',
      required: ['namespace'],
      properties: {
        namespace: {
          type: 'string'
        },
        conditions: {
          type: 'array',
          items: {
            type: 'string'
          }
        }
      }
    }
  end
end
