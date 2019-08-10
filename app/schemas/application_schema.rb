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
      raise Polydesk::ApiExceptions::MalformedRequest.new
    else
      data
    end
  end

  def schema
    {}
  end
end
