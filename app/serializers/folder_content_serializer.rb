class FolderContentSerializer
  def initialize(content, options)
    if !content.respond_to?(:map)
      content = [content]
    end

    @data = content.map { |item|
      JSONAPI::Serializer.serialize(item)[:data]
    }
    @pagination = options
  end

  def serialized_json
    {
      data: @data
    }.merge(@pagination).to_json
  end
end
