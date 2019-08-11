class CreateReportSchema < ApplicationSchema
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
              enum: ['reports']
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
