class UpdateUserSchema < ApplicationSchema
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
              enum: 'users'
            },
            attributes: {
              type: 'object',
              properties: {
                'first-name': {
                  type: 'string'
                },
                'last-name': {
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
