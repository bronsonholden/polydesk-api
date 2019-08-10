class CreateFormSubmissionSchema < ApplicationSchema
  def schema
    {
      type: 'object',
      required: ['data'],
      properties: {
        data: {
          type: 'object',
          required: [
            'type',
            'attributes',
            'relationships'
          ],
          properties: {
            type: {
              type: 'string',
              enum: ['form-submissions']
            },
            attributes: {
              type: 'object',
              required: ['data'],
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
            },
            relationships: {
              type: 'object',
              required: ['form'],
              properties: {
                form: {
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

  # schema type: Strict::Hash do
  #   field :id, type: Strict::Nil
  #   field :controller, type: Strict::String.enum('form_submissions')
  #   field :action, type: Strict::String.enum('create')
  #   field :data, type: Strict::Hash do
  #     field :type, type: Strict::String.enum('form-submissions')
  #     field :attributes, type: Strict::Hash.optional do
  #       field :data, type: Strict::Hash.optional
  #       field :state, type: Strict::String.enum('draft', 'published').optional
  #     end
  #     field :relationships, type: Strict::Hash.optional do
  #       field :form, type: Strict::Hash.optional do
  #         field :data, type: Strict::Hash do
  #           field :id, type: Strict::String
  #           field :type, type: Strict::String.enum('forms')
  #         end
  #       end
  #     end
  #   end
  # end
end
