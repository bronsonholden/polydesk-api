class CreateBlueprintSchema < ApplicationSchema
  def schema
    {
      type: 'object',
      required: ['data'],
      properties: {
        data: {
          type: 'object',
          required: ['type', 'attributes'],
          properties: {
            type: {
              type: 'string',
              enum: ['blueprints']
            },
            attributes: {
              type: 'object',
              required: ['name', 'namespace', 'schema'],
              properties: {
                name: {
                  type: 'string'
                },
                namespace: {
                  type: 'string'
                },
                schema: {
                  type: 'object'
                }
              }
            }
          }
        }
      }
    }
  end
end
