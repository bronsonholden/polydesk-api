class CreatePrefabSchema < ApplicationSchema
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
              enum: ['prefabs']
            },
            attributes: {
              type: 'object',
              required: ['namespace', 'schema', 'view', 'data'],
              properties: {
                namespace: {
                  type: 'string'
                },
                schema: {
                  type: 'object'
                },
                view: {
                  type: 'object'
                },
                data: {
                  type: 'object'
                }
              }
            },
            relationships: {
              type: 'object',
              required: ['blueprint'],
              properties: {
                blueprint: {
                  type: 'object',
                  required: ['data'],
                  properties: {
                    data: {
                      type: 'object',
                      required: ['id', 'type'],
                      properties: {
                        id: {
                          type: 'string',
                        },
                        type: {
                          type: 'string',
                          enum: ['blueprints']
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  end
end
