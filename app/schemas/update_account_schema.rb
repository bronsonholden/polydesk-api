class UpdateAccountSchema < ApplicationSchema
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
              enum: 'accounts'
            },
            attributes: {
              type: 'object',
              properties: {
                name: {
                  type: 'string'
                }
              }
            }
          }
        }
      }
    }
  end
end
