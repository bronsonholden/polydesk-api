class ApplicationSchema
  attr_reader :data

  def initialize(data)
    @data = data
  end

  def validate
    JSON::Validator.validate(schema, data)
  end

  def render
    if !validate
      # TODO: return validation errors as part of response...
      raise Polydesk::Errors::MalformedRequest.new
    end

    # TODO: Apply default pagination in a more appropriate place
    res = data
    if !res.key?('page')
      res['page'] = {
        'limit' => '25',
        'offset' => '0'
      }
    else
      page = res.fetch('page')
      page['limit'] = '25' if !page.key?('limit')
      page['offset'] = '0' if !page.key?('offset')
    end
    res
  end

  def schema
    {}
  end

  def include_schema
    {
      type: 'string',
      minLength: 1
    }
  end

  def sort_schema
    {
      type: 'array'
    }
  end

  def fields_schema
    {
      type: 'object'
    }
  end

  def filter_schema
    {
      type: 'array'
    }
  end

  def page_schema
    {
      type: 'object',
      properties: {
        offset: {
          type: 'string'
        },
        limit: {
          type: 'string'
        }
      }
    }
  end
end
