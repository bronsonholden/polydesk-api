class UpdateFormSchema < ApplicationSchema
  def schema
    {
      type: 'object',
      required: ['data'],
      properties: {
        data: {
          type: 'object',
          required: [
            'id',
            'type'
          ],
          properties: {
            id: {
              type: 'string'
            },
            type: {
              type: 'string',
              enum: ['forms']
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
                layout: {
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
