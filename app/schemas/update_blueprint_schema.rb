class UpdateBlueprintSchema < ApplicationSchema
  def schema
    {
      type: 'object',
      required: ['data'],
      properties: {
        data: {
          type: 'object',
          required: ['id', 'type', 'attributes'],
          properties: {
            id: {
              type: 'string',
            },
            type: {
              type: 'string',
              enum: ['blueprints']
            },
            attributes: {
              type: 'object',
              properties: {
                name: {
                  type: 'string'
                },
                schema: {
                  type: 'object'
                },
                view: {
                  type: 'object'
                },
                'construction-view' => {
                  type: 'object'
                },
                'list-view' => {
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
