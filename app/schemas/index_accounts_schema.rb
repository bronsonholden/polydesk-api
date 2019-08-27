class IndexAccountsSchema < ApplicationSchema
  def schema
    {
      type: 'object',
      properties: {
        filter: filter_schema,
        page: page_schema,
        sort: sort_schema
      }
    }
  end
end
