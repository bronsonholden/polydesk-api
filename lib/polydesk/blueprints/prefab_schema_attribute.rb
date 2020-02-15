module Polydesk
  module Blueprints
    # This validates that a property with the "prefab" attribute defined
    # actually meets the criteria specified by that subschema.
    class PrefabSchemaAttribute < JSON::Schema::Attribute
      def self.validate(current_schema, data, fragments, processor, validator, options = {})
        uid = data
        m = data.match(/^([a-z]+)\/(\d+)$/)
        return if m.nil?
        namespace = m[1]
        tag = m[2]
        reference = Prefab.where(namespace: namespace, tag: tag)
        schema = current_schema.schema
        prefab_criteria = schema['prefab']
        if !prefab_criteria.nil?
          scope = PrefabCriteriaScoping.apply(prefab_criteria.to_json, reference)
          if scope.where(namespace: namespace, tag: tag).empty?
            message = "#{reference.first.namespace}/#{reference.first.tag} does not meet criteria for reference"
            validation_error(processor, message, fragments, current_schema, self, options[:record_errors])
          end
        end
      end
    end
  end
end
