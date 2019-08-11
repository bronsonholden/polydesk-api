class CreateUserSchema < ApplicationSchema
  def schema
    {
      type: 'object',
      required: ['data'],
      properties: {
        data: {
          type: 'object',
          required: [
            'type',
            'attributes'
          ],
          properties: {
            type: {
              type: 'string',
              enum: ['users']
            },
            attributes: {
              type: 'object',
              required: [
                'first-name',
                'last-name',
                'email',
                'password',
                'password-confirmation'
              ],
              properties: {
                'first-name': {
                  type: 'string'
                },
                'last-name': {
                  type: 'string'
                },
                email: {
                  type: 'string'
                },
                password: {
                  type: 'string'
                },
                'password-confirmation': {
                  type: 'string'
                }
              }
            },
            relationships: {
              accounts: {
                type: 'object',
                required: ['data'],
                properties: {
                  data: {
                    type: 'array',
                    items: {
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
                          enum: ['accounts']
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
