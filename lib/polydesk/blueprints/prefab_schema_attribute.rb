module Polydesk
  module Blueprints
    # This validates that a property with the "prefab" attribute defined
    # actually meets the criteria specified by that subschema.
    class PrefabSchemaAttribute < JSON::Schema::Attribute
      def self.validate(current_schema, data, fragments, processor, validator, options = {})
        uid = data
        m = data.match(/^([a-z]+)\/(\d+)$/)
        namespace = m[1]
        tag = m[2]
        scope = Prefab.all
        schema = current_schema.schema
        prefab_criteria = schema['prefab']
        if !prefab_criteria.nil?
          scope = PrefabCriteriaScoping.apply(prefab_criteria.to_json, scope)
          if scope.where(namespace: namespace, tag: tag).any?
            puts 'exists'
          else
            puts 'nope'
          end
        end
      end
    end
  end
end
