class CreatePrefabSchema < ApplicationSchema
  def schema
    {
      type: 'object',
      required: ['data'],
      properties: {
        data: {
          oneOf: [
            {
              type: 'object',
              additionalProperties: false,
              required: ['type', 'attributes'],
              properties: {
                type: {
                  type: 'string',
                  enum: ['prefabs']
                },
                attributes: {
                  type: 'object',
                  additionalProperties: false,
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
                }
              }
            },
            {
              type: 'object',
              additionalProperties: false,
              required: ['type', 'attributes'],
              properties: {
                type: {
                  type: 'string',
                  enum: ['prefabs']
                },
                attributes: {
                  type: 'object',
                  additionalProperties: false,
                  required: ['data'],
                  properties: {
                    data: {
                      type: 'object'
                    }
                  }
                },
                relationships: {
                  type: 'object',
                  additionalProperties: false,
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
          ]
        }
      }
    }
  end
end
