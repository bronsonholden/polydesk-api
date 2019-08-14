class ShowDocumentSchema < ApplicationSchema
  def schema
    {
      type: 'object',
      properties: {
        include: include_schema,
        fields: fields_schema,
        filter: filter_schema
      }
    }
  end
end
