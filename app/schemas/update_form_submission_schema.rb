class UpdateFormSubmissionSchema < ApplicationSchema
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
              enum: 'form-submissions'
            },
            attributes: {
              type: 'object',
              properties: {
                data: {
                  type: 'object'
                },
                state: {
                  type: 'string',
                  enum: [
                    'draft',
                    'published'
                  ]
                }
              }
            }
          }
        }
      }
    }
  end
end
