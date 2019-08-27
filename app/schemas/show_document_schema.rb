class ShowDocumentSchema < ApplicationSchema
  def schema
    {
      type: 'object',
      properties: {
        fields: fields_schema,
        filter: filter_schema
      }
    }
  end
end
