class IndexFoldersSchema < ApplicationSchema
  def schema
    {
      type: 'object',
      properties: {
        include: include_schema,
        filter: filter_schema,
        page: page_schema,
        sort: sort_schema
      }
    }
  end
end
