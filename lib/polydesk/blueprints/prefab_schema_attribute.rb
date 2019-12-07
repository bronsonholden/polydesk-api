module Polydesk
  module Blueprints
    # This validates that a property with the "prefab" attribute defined
    # actually meets the criteria specified by that subschema.
    class PrefabSchemaAttribute < JSON::Schema::Attribute
      def self.validate(schema, data, fragments, processor, validator, options = {})
      end
    end
  end
end
