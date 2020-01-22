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
              required: ['name', 'namespace', 'schema', 'view'],
              properties: {
                name: {
                  type: 'string'
                },
                namespace: {
                  type: 'string'
                },
                schema: {
                  type: 'object'
                },
                view: {
                  type: 'object'
                },
                construction_view: {
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
