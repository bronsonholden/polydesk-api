class UpdateFolderSchema < ApplicationSchema
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
              enum: ['folders']
            },
            attributes: {
              type: 'object',
              properties: {
                name: {
                  type: 'string'
                }
              }
            },
            relationships: {
              type: 'object',
              properties: {
                folder: {
                  oneOf: [
                    {
                      type: 'null'
                    },
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
                              enum: ['folders']
                            }
                          }
                        }
                      }
                    }
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
