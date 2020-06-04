# This validates that a property with the "prefab" subschema defined
# actually meets the criteria specified by that subschema.
class PrefabSchemaAttribute < JSON::Schema::Attribute
  def self.validate(current_schema, data, fragments, processor, validator, options = {})
    uid = data
    m = data.match(/^([a-z]+)\/(\d+)$/)
    return if m.nil?
    namespace = m[1]
    id = m[2]
    # TODO: Apply data controls to base scope, so if e.g. access to the given
    # namespace is restricted, the result set will always be empty and
    # validation will fail.
    reference = Prefab.where(namespace: namespace, id: id)
    schema = current_schema.schema
    prefab_criteria = schema['prefab']
    if !prefab_criteria.nil?
      payload = {
        'filter' => schema.fetch('conditions', [])
      }
      scope = PrefabQuery.new(payload).apply(reference)
      if scope.empty?
        message = "#{reference.first.namespace}/#{reference.first.tag} does not meet criteria for reference"
        validation_error(processor, message, fragments, current_schema, self, options[:record_errors])
      end
    end
  end
end
