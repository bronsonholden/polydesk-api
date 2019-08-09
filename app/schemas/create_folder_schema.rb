class CreateFolderSchema < ApplicationSchema
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
              enum: ['folders']
            },
            attributes: {
              type: 'object',
              required: ['name'],
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
