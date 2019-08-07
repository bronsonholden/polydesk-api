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
      nil
    else
      data
    end
  end

  def schema
    {}
  end
end
