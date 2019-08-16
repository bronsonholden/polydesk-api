class UploadDocumentSchema < ApplicationSchema
  def schema
    {
      type: 'object',
      properties: {
        name: {
          type: 'string'
        }
      }
    }
  end
end
