class IndexUsersSchema < ApplicationSchema
  def schema
    {
      type: 'object',
      properties: {
        include: include_schema,
        fields: fields_schema,
        filter: filter_schema,
        page: page_schema,
        sort: sort_schema
      }
    }
  end
end
