class CreateFormSchema < ApplicationSchema
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
              enum: ['forms']
            },
            attributes: {
              type: 'object',
              required: [
                'name',
                'schema'
              ],
              properties: {
                name: {
                  type: 'string'
                },
                schema: {
                  type: 'object'
                },
                layout: {
                  type: 'object'
                },
                'unique-fields' => {
                  type: 'array',
                  items: {
                    type: 'string'
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
