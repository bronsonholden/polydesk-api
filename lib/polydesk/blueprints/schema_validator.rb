module Polydesk
  module Blueprints
    class SchemaValidator < JSON::Schema::Draft3
      def initialize
        super
        @attributes['prefab'] = Polydesk::Blueprints::PrefabSchemaAttribute
        @uri = JSON::Util::URI.parse('https://polydesk.io/blueprint-schema.json')
        @names = ['https://polydesk.io/blueprint-schema.json']
      end

      JSON::Validator.register_validator(self.new)
    end
  end
end
