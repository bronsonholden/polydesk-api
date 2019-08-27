class IndexUsersSchema < ApplicationSchema
  def schema
    {
      type: 'object',
      properties: {
        fields: fields_schema,
        filter: filter_schema,
        page: page_schema,
        sort: sort_schema
      }
    }
  end
end
